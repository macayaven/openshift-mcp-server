# Phase 2: Schema and Structure Alignment - Analysis

**Date**: 2025-10-30
**Branch**: 002-schema-alignment
**Status**: Analysis Complete, Ready for Implementation

---

## Overview

This document analyzes the differences between the core Kubernetes toolsets and the OpenShift AI toolsets, identifying patterns to align and standardize.

## Key Differences Identified

### 1. Tool Definition Location and Pattern

#### Core Toolset Pattern (pkg/toolsets/core/pods.go)
```go
func initPods() []api.ServerTool {
    return []api.ServerTool{
        {Tool: api.Tool{
            Name:        "pods_list",
            Description: "List all the Kubernetes pods...",
            InputSchema: &jsonschema.Schema{
                Type: "object",
                Properties: map[string]*jsonschema.Schema{
                    "labelSelector": {
                        Type:        "string",
                        Description: "Optional Kubernetes label selector...",
                        Pattern:     "([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9]",
                    },
                },
            },
            Annotations: api.ToolAnnotations{
                Title:           "Pods: List",
                ReadOnlyHint:    ptr.To(true),
                DestructiveHint: ptr.To(false),
                IdempotentHint:  ptr.To(false),
                OpenWorldHint:   ptr.To(true),
            },
        }, Handler: podsListInAllNamespaces},
    }
}
```

**Key Characteristics:**
- Tool definition is inline in the toolset file
- Handler function is defined in the same file
- Direct access to `api.Tool` struct
- Handlers are simple functions, not methods
- Clear separation of tool definition and handler logic

#### OpenShift AI Pattern (pkg/toolsets/openshift-ai/applications.go)
```go
func (t *ApplicationsToolset) GetTools(o kubernetes.Openshift) []api.ServerTool {
    return []api.ServerTool{
        {
            Tool: api.GetApplicationsListTool(),  // Tool defined in pkg/api/datascience_project.go
            Handler: func(params api.ToolHandlerParams) (*api.ToolCallResult, error) {
                return t.handleApplicationsList(params)
            },
        },
    }
}
```

**Key Characteristics:**
- Tool definitions are in separate file (pkg/api/datascience_project.go)
- Handler methods are on the toolset struct
- Anonymous function wrapper for handler
- Toolset uses a base struct pattern
- Client retrieval happens in each handler

### 2. Schema Definition Patterns

#### Core Pattern
- Inline `InputSchema` with `jsonschema.Schema`
- Direct property definitions
- Consistent use of `labelSelector` (camelCase)
- Pattern validation where appropriate
- Required fields clearly marked

#### OpenShift AI Pattern
- Separate tool definition functions (e.g., `GetApplicationsListTool()`)
- Similar schema structure but in different location
- Inconsistent naming: `app_type` (snake_case) vs camelCase in core
- Less pattern validation

### 3. Parameter Naming Conventions

| Resource Type | Core Pattern | OpenShift AI Pattern | Issue |
|--------------|--------------|---------------------|-------|
| Label filtering | `labelSelector` | N/A (no label selectors) | Missing feature |
| Type filtering | N/A | `app_type`, `model_type` | snake_case vs camelCase |
| Namespace | `namespace` (optional in list, required in get) | `namespace` (same pattern) | ✅ Consistent |
| Name | `name` (required) | `name` (required) | ✅ Consistent |

### 4. Handler Patterns

#### Core Pattern
```go
func podsListInAllNamespaces(params api.ToolHandlerParams) (*api.ToolCallResult, error) {
    labelSelector := params.GetArguments()["labelSelector"]
    resourceListOptions := kubernetes.ResourceListOptions{
        AsTable: params.ListOutput.AsTable(),
    }
    if labelSelector != nil {
        resourceListOptions.LabelSelector = labelSelector.(string)
    }
    ret, err := params.PodsListInAllNamespaces(params, resourceListOptions)
    if err != nil {
        return api.NewToolCallResult("", fmt.Errorf("failed to list pods: %v", err)), nil
    }
    return api.NewToolCallResult(params.ListOutput.PrintObj(ret)), nil
}
```

**Characteristics:**
- Simple function (not a method)
- Direct parameter extraction
- Uses `params.ListOutput` for formatting
- Standard error handling pattern
- Returns structured Kubernetes objects

#### OpenShift AI Pattern
```go
func (t *ApplicationsToolset) handleApplicationsList(params api.ToolHandlerParams) (*api.ToolCallResult, error) {
    args := params.GetArguments()
    namespace, _ := args["namespace"].(string)
    status, _ := args["status"].(string)
    appType, _ := args["app_type"].(string)

    // Get OpenShift AI client from Kubernetes manager
    clientInterface, err := params.Kubernetes.GetOrCreateOpenShiftAIClient(func(cfg *rest.Config, config interface{}) (interface{}, error) {
        return openshiftai.NewClient(cfg, nil)
    })
    if err != nil {
        return api.NewToolCallResult("", fmt.Errorf("failed to get OpenShift AI client: %w", err)), nil
    }
    openshiftAIClient := clientInterface.(*openshiftai.Client)

    applicationClient := openshiftai.NewApplicationClient(openshiftAIClient)
    applications, err := applicationClient.List(params.Context, namespace, status, appType)
    if err != nil {
        return api.NewToolCallResult("", fmt.Errorf("failed to list applications: %w", err)), nil
    }

    // Convert to JSON response
    content, err := json.Marshal(applications)
    if err != nil {
        return api.NewToolCallResult("", fmt.Errorf("failed to marshal applications: %w", err)), nil
    }

    return api.NewToolCallResult(string(content), nil), nil
}
```

**Characteristics:**
- Method on toolset struct
- Parameter extraction with type assertion
- Client creation per call (cached after Phase 1, but still retrieved)
- JSON marshaling instead of structured output
- More verbose error handling

### 5. Output Format

| Aspect | Core Pattern | OpenShift AI Pattern | Issue |
|--------|--------------|---------------------|-------|
| List output | Uses `params.ListOutput.PrintObj()` | JSON marshaling | Inconsistent |
| Get output | Uses `output.MarshalYaml()` | JSON marshaling | Inconsistent |
| Error messages | Structured with context | Similar pattern | ✅ Mostly consistent |

### 6. Annotations Comparison

#### Core Pods List Tool
```go
Annotations: api.ToolAnnotations{
    Title:           "Pods: List",
    ReadOnlyHint:    ptr.To(true),
    DestructiveHint: ptr.To(false),
    IdempotentHint:  ptr.To(false),
    OpenWorldHint:   ptr.To(true),
}
```

#### OpenShift AI Applications List Tool
```go
Annotations: ToolAnnotations{
    Title:           "Applications: List",
    ReadOnlyHint:    ptr.To(true),
    DestructiveHint: ptr.To(false),
    IdempotentHint:  ptr.To(true),  // Different from core!
    OpenWorldHint:   ptr.To(false), // Different from core!
}
```

**Issues:**
- `IdempotentHint` differs (core: false, OpenShift AI: true for list operations)
- `OpenWorldHint` differs (core: true, OpenShift AI: false for list operations)
- Need to verify correct semantics for these hints

---

## Alignment Plan

### Task 2.1: Standardize Parameter Naming

**Changes Required:**
1. ✅ Keep `namespace` as-is (already consistent)
2. ✅ Keep `name` as-is (already consistent)
3. 🔧 Change `app_type` → `appType` (or consider `type` for consistency)
4. 🔧 Change `model_type` → `modelType` (or `type`)
5. 🔧 Consider adding `labelSelector` support to OpenShift AI tools where applicable

**Files to Modify:**
- `pkg/api/datascience_project.go` - Update all tool schemas
- `pkg/toolsets/openshift-ai/*.go` - Update parameter extraction in handlers

### Task 2.2: Standardize Tool Definition Location

**Decision Point:** Should we:
- **Option A**: Move tool definitions inline with handlers (like core)?
- **Option B**: Keep tool definitions in pkg/api but make pattern more consistent?
- **Option C**: Hybrid approach - simple tools inline, complex tools in pkg/api?

**Recommendation**: Option B - Keep in pkg/api for better separation of concerns
- OpenShift AI has more complex schemas
- API types are well-organized in one file
- Easier to maintain and version
- Just need to ensure consistency with core patterns

### Task 2.3: Standardize InputSchema Validation

**Changes Required:**
1. Add pattern validation where appropriate (e.g., namespace names, resource names)
2. Ensure consistent use of `Required` fields
3. Add description for all parameters
4. Consider adding `enum` constraints for known types (e.g., appType, modelType)

**Example:**
```go
"appType": {
    Type:        "string",
    Description: "Filter by application type",
    Enum:        []string{"Jupyter", "CodeServer", "RStudio"}, // Add enum
},
```

### Task 2.4: Align Tool Definition Structure

**Core Pattern to Follow:**
```go
{Tool: api.Tool{
    Name:        "resource_action",
    Description: "Action description",
    InputSchema: &jsonschema.Schema{...},
    Annotations: api.ToolAnnotations{...},
}, Handler: handlerFunction}
```

**Current OpenShift AI Pattern:**
```go
{
    Tool: api.GetApplicationsListTool(),
    Handler: func(params api.ToolHandlerParams) (*api.ToolCallResult, error) {
        return t.handleApplicationsList(params)
    },
}
```

**Recommendation**: Keep using `api.GetApplicationsListTool()` but ensure:
- Tool definition functions follow consistent naming
- All tools have complete annotations
- Schemas are consistent with core patterns

### Task 2.5: Standardize Handler Signatures

**Decision**: Keep method-based handlers for OpenShift AI
- More complex client management
- Toolset state management needed
- Consistent with OOP patterns
- Just ensure parameter extraction is consistent

### Task 2.6: Standardize Tool Naming

**Core Pattern**: `resource_action` (e.g., `pods_list`, `pods_get`, `pods_delete`)

**OpenShift AI Pattern**: Mix of patterns
- `applications_list` ✅
- `application_get` ✅
- `datascience_projects_list` ✅
- `model_create` ✅
- Seems mostly consistent!

**Verification Needed**: Check all tool names across all OpenShift AI toolsets

### Task 2.7: API Type Consistency

**Issues to Address:**
1. Ensure all API types in `pkg/api/datascience_project.go` follow Go naming conventions
2. Use pointer types consistently for optional fields
3. Ensure Status structs are consistent across resources
4. Consider adding common interfaces for resources

### Task 2.8: Standardize Output Formatting

**Current Issues:**
- Core uses `params.ListOutput.PrintObj()` and `output.MarshalYaml()`
- OpenShift AI uses `json.Marshal()` directly

**Recommendation:**
- Align OpenShift AI to use same output patterns as core
- Use `params.ListOutput` for list operations
- Use `output.MarshalYaml()` for get operations
- Ensures consistent user experience

### Task 2.9: Verify and Fix Annotations

**Review Needed:**
- `IdempotentHint` semantics (should list be idempotent?)
- `OpenWorldHint` semantics (should list operations be open world?)
- Ensure consistency across all tools

**Idempotent Definition**: Operation can be repeated without changing result
- List operations: Could be idempotent if results are deterministic
- Get operations: Should be idempotent
- Create operations: Not idempotent (creates new resource)
- Delete operations: Could be idempotent (deleting non-existent is OK)

**OpenWorld Definition**: Operation returns partial/incomplete information
- List operations in core: `true` (may not show all pods due to RBAC)
- List operations in OpenShift AI: `false` (why?)
- Need to verify correct semantics

---

## Implementation Order

### Phase 2.1: Schema Standardization (Current Focus)
1. ✅ Analysis complete
2. Update parameter naming conventions
3. Add schema validation patterns
4. Standardize required fields

### Phase 2.2: Structure Alignment
1. Ensure tool definition consistency
2. Verify naming conventions
3. Standardize annotations

### Phase 2.3: Output and Handler Consistency
1. Align output formatting
2. Ensure consistent error handling
3. Test all changes

---

## Files Requiring Changes

### Schema Changes:
- `pkg/api/datascience_project.go` (all tool definitions)

### Handler Changes:
- `pkg/toolsets/openshift-ai/applications.go`
- `pkg/toolsets/openshift-ai/datascience_projects.go`
- `pkg/toolsets/openshift-ai/experiments.go`
- `pkg/toolsets/openshift-ai/models.go`
- `pkg/toolsets/openshift-ai/pipelines.go`

### Test Updates:
- Snapshot tests will need regeneration
- Config tests may need updates

---

## Success Criteria

- [ ] All parameter names follow camelCase convention (consistent with core)
- [ ] All schemas have complete validation (patterns, enums where appropriate)
- [ ] All tool names follow `resource_action` pattern
- [ ] All handlers use consistent output formatting
- [ ] All annotations are semantically correct
- [ ] All tests passing
- [ ] Code follows established patterns from core toolsets

---

## Notes

- Some differences may be intentional (e.g., separate API file for complex types)
- Need to balance consistency with maintainability
- OpenShift AI tools are more complex than core Kubernetes resources
- Consider creating a style guide for future toolset development
