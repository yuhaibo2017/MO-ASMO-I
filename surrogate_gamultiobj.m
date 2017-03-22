% This function runs multiobjective optimization on the surrogate model
% using genetic algorithm based solver (MATLAB intrinsic gamultiobj).
% Usage: MO = SURROGATE_GAMULTIOBJ(SM,problem,initpop)
% Input: SM,problem,initpop
% Output: MO
%   SM: surrogate model data structure
%   problem: problem definition structure
%   initpop: initial population for genetic algorithm
%   MO: result structure containing Pareto-optimal solutions and outputs

% Multiobjective Adaptive Surrogate Modeling-based Optimization Toolbox I
% Author: Yong Hoon Lee (ylee196@illinois.edu, yonghoonlee@outlook.com)
% Please refer to LICENSE.TXT for licensing details.
% Some directories may include codes from different author or with
% different license. In this case, please refer to LICENSE file or
% LICENSE.TXT file in each corresponding subdirectories.

function MO = surrogate_gamultiobj(SM,problem,initpop)
    if (problem.control.verbose > 0)
        fprintf('%s','Solving multiobjective optimization...');
    end
    opt = problem.gamultiobj.opt;
    A = problem.A;
    b = problem.b;
    Aeq = problem.Aeq;
    beq = problem.beq;
    lb = problem.xlb;
    ub = problem.xub;
    nxvar = problem.nxvar;
    nonlconfun = problem.nonlconfun;
    % Modify options
    if size(initpop,1) > 1
        opt.InitialPopulation = initpop;
    end
    if ((problem.gamultiobj.parallel ~= 0) && (hff_getpoolsize ~= 0))
        opt.Vectorized = 'off';
        opt.UseParallel = true;
    end
    % Run multiobjective optimization using gamultiobj
    [xopt,fopt,ef,out,pop,scr] = gamultiobj(@(x)surrogate_eval(x,SM),...
        nxvar,A,b,Aeq,beq,lb,ub,@(x)nonlconfun(x),opt);
    % Maintain unique solutions only
    xsize = size(xopt,2);
    xcomb = [xopt,fopt];
    xcomb = unique(xcomb,'rows');
    % Save to MO structure
    MO.x = xcomb(:,1:xsize);
    MO.f = xcomb(:,(xsize + 1):end);
    MO.exitflag = ef;
    MO.output = out;
    MO.population = pop;
    MO.score = scr;
    if (problem.control.verbose > 0)
        fprintf('%s','done');
    end
end