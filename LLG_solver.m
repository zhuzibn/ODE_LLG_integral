%% LLG equation with precession term, damping term, spin current
% usage: add path which contain this file, call the function
% don't create the same function in new project 
function dmdt=LLG_solver(alp,mmm,hh,p,a_parallel,a_perpendicular)
% call this function by feval(@(t,m) LLG_solver(t,m,Hk,alpha),t0,m0)
% t0 is the initial value of t
% m0 is the initial value of m
    
    dmdt=-cross(mmm,hh)-alp*cross(mmm,cross(mmm,hh))-a_parallel*cross(mmm,...
    cross(mmm,p))+alp*a_parallel*cross(mmm,p)+a_perpendicular*cross(mmm,p)+...
    alp*a_perpendicular*cross(mmm,cross(mmm,p));

end