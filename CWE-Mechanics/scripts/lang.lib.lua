---------------------------------------------------------------------
-- TABLE EXTENTIONS -------------------------------------------------


function AddElem(table, value)
    local index = length(table)
    table[index] = value
end


---------------------------------------------------------------------

function pow_int(x, n)
    local result = 1
    local multiplier = x;
    if n < 0 then multiplier = 1 / x end

    for i = 1, n do
        result = result * multiplier
    end

    return result
end

