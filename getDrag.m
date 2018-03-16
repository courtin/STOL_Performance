%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%getDrag is a pass-through function that calls the 
%other drag modules.  This is for the convenience of
%not needing to change code in other places to change the 
%drag model. 
%
%   OUTPUTS:
%
%   Params      CD_total        Float giving the total drag on the aircraft
%                               at the specified flight condition; this     
%               Drag_Decomp     Structure containing any other relevant
%                               drag values calculated in the buildup of CD_total 
%
    
function [CD_total, Drag_Decomp] = getDrag(airplane, alt, M, CL, config)
    if isfield(airplane.current_state, 'CJ')
        CJ = airplane.current_state.CJ;
       [CD_total, Drag_Decomp] = blownDrag(airplane, alt, M, CL, CJ, config);
    else
        [CD_total, Drag_Decomp] = basicDrag(airplane, alt, M, CL, config);
    end
    
end