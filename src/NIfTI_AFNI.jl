module NIfTI_AFNI

using NIfTI,LightXML

export isafni,AFNIExtension,NIfTI1Extension

"""isafni(e::NIfTI.NIfTI1Extension)

Is this an AFNI Extension?"""
isafni(e::NIfTI.NIfTI1Extension) = e.ecode==4

"""parse_quotedstrings(a::AbstractString)

A simple function to parse apart the strings in AFNI NIfTI Extensions"""
function parse_quotedstrings(a::AbstractString)
    strings = SubString[]
    stringstart = 0
    stringend = 0

    i = 1
    while i<=length(a)
        a[i] == '\\' && (i += 2; continue)

        if a[i]=='"'
            if stringstart==0
                stringstart = i+1
                stringend = 0
            elseif stringend==0
                push!(strings,SubString(a,stringstart,i-1))
                stringstart = 0
            end
        end
        i += 1
    end
    strings
end

mutable struct AFNIExtension
    ecode::Int32
    edata::Vector{UInt8}
    
    raw_xml::String
    header::Dict{String,Any}
end 
 

function AFNIExtension(e::NIfTI.NIfTI1Extension)
    isafni(e) || error("Trying to convert an unknown NIfTIExtension to AFNIExtension")
    
    edata = copy(e.edata)
    raw_xml = String(e.edata)

    xdoc = parse_string(raw_xml)
    xroot = root(xdoc)

    header_dict = Dict{String,Any}()

    for atr in xroot["AFNI_atr"]
        t = attribute(atr,"ni_type")
        n = attribute(atr,"atr_name")

        if t=="String"
            header_dict[n] = parse_quotedstrings(content(atr))
        elseif t=="int"
            header_dict[n] = parse.(Int,split(content(atr)))
        elseif t=="float"
            header_dict[n] = parse.(Float64,split(content(atr)))
        end

        isa(header_dict[n],AbstractArray) && length(header_dict[n])==1 && (header_dict[n] = header_dict[n][1])
        n == "BRICK_LABS" && (header_dict[n] = split(header_dict[n],"~"))
        n == "BRICK_STATSYM" && (header_dict[n] = split(header_dict[n],";"))
    end
    
    free(xdoc)
    AFNIExtension(e.ecode,edata,raw_xml,header_dict)
end

NIfTI1Extension(a::AFNIExtension) = NIfTI.NIfTI1Extension(a.ecode,a.edata)


end # module
