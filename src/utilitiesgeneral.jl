"""
$(TYPEDSIGNATURES)
"""
function calculate_direction(vel::Union{NTuple{2,T}, Vect{2, T}}) where T<:Real #for 2d and graph
    vx, vy = vel
    if (vx ≈ 0.0)
        return 0.0
    end
    if (vx > 0)
        return 1.5*pi+atan(vy/vx)
    end
    if (vx<0) 
        return 0.5*pi+atan(vy/vx)
    end 
end


"""
$(TYPEDSIGNATURES)
"""
function calculate_direction(vel::Union{NTuple{3,T}, Vect{3, T}}) where T<:Real
    vx, vy, vz = vel
    ln = sqrt(vx^2+vy^2+vz^2)
    if (ln ≈ 0.0)
        return 0.0
    end
    orientation = vel/ln
    return orientation
end



"""
$(TYPEDSIGNATURES)

Saves the model on disk as jld2 file. 
"""
function save_model(model; model_name::String = _default_modelname, save_as = _default_filename, folder = _default_folder[])
    _save_object_to_disk(model, name = model_name, save_as = save_as, folder = folder)
end 


"""
$(TYPEDSIGNATURES)

Gets the model that was saved before as jld2. 
"""
function open_saved_model(; model_name = _default_modelname, path = joinpath(_default_folder[], _default_filename))
    try
        f = jldopen(path, "r+")
        model = f[model_name]
        close(f)
        return model
    catch e
        print("Error opening file: ", e)
    end
end


@inline function _default_true(agent::AbstractPropDict)
    return true
end


"""
$(TYPEDSIGNATURES)
"""
@inline function num_agents(model::Union{AbstractSpaceModel, AbstractGraphModel }, condition::Function)
    return count(x->true, get_agents(model, condition))
end

"""
$(TYPEDSIGNATURES)
"""
@inline function num_agents(model::Union{AbstractSpaceModel, AbstractGraphModel })
    return model.parameters._extras._num_agents::Int # number of active agents
end


"""
$(TYPEDSIGNATURES)

Returns agents id.
"""
function get_id(agent::AbstractAgent)
    return getfield(agent, :id)
end

"""
$(TYPEDSIGNATURES)

Returns true if agent is alive else returns false.
"""
function is_alive(agent::AbstractPropDict)
    return agent._extras._active::Bool
end


"""
$(TYPEDSIGNATURES)

Returns true if a node is alive else returns false.
"""
function is_alive(node, model::AbstractGraphModel)
    return model.graph.nodesprops[node]._extras._active::Bool
end


"""
$(TYPEDSIGNATURES)

Returns true if a patch is occupied.
"""
function is_occupied(patch, model::AbstractSpaceModel)
    return length(model.patches[patch...].agents) > 0 
end


"""
$(TYPEDSIGNATURES)

Returns true if a node is occupied. 
"""
function is_occupied(node, model::AbstractGraphModel)
    return length(model.graph.nodesprops[node].agents) > 0 
end


"""
$(TYPEDSIGNATURES)

Returns an empty node chosen at random. Returns nothing if there is no empty node. 
"""
function random_empty_node(model::AbstractGraphModel)
    verts = getfield(model.graph, :_nodes)
    empty_verts = verts[[!(is_occupied(node, model)) for node in verts]]
    n = length(empty_verts)
    if n >0
        m = rand(1:n)
        return empty_verts[m]
    else
        return nothing
    end
end



"""
$(TYPEDSIGNATURES)

Returns number of agents at a given patch.
"""
function num_agents_at(patch, model::AbstractSpaceModel)
    return count(x->true, agents_at(patch, model))
end


"""
$(TYPEDSIGNATURES)

Returns number of agents at a given node. 
"""
function num_agents_at(node, model::AbstractGraphModel)
    return count(x->true,agents_at(node, model))
end


"""
$(TYPEDSIGNATURES)

Returns value of given property of a patch. 
"""
function get_patchprop(key, patch, model::AbstractSpaceModel)
    return unwrap(model.patches[patch...])[key]
end


"""
$(TYPEDSIGNATURES)

Sets properties of the patch given as keyword arguments. 
"""
function set_patchprops!(patch, model::AbstractSpaceModel; kwargs...)
    dict = Dict{Symbol, Any}(kwargs...)
    patch_dict = unwrap(model.patches[patch...])
    patch_data = unwrap_data(model.patches[patch...])
    for (key, val) in dict
        patch_dict[key] = val
        if !haskey(patch_data, key)
            patch_data[key] = typeof(val)[]
        end
    end
end
