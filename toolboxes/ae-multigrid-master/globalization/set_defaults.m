% Set default values for parameter fields not specified by the user.
%
% params = set_defaults(params, params_def)
%
% Copy any fields specified in params_def but not params into params.
% If params is empty, then set params to params_def.
%
% Input:
%    params     - struct containing partial parameter settings (or [])
%    params_def - struct containing default parameter settings
%
% Output:
%    parms      - struct with defaults filled in for missing parameter fields
function params = set_defaults(params, params_def)
   % check whether to copy all defaults
   if (isempty(params))
      % return default parameters
      params = params_def;
   else
      % set default values for any unspecified parameters
      names = setdiff(fieldnames(params_def),fieldnames(params));
      for n = 1:numel(names)
         params = setfield(params, names{n}, getfield(params_def, names{n}));
      end
   end
end
