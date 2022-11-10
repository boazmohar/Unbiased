function width = Diffusion_1D_BM_fun(in_rate, plot_flag, video_flag)
% Simulating the 1-D Diffusion equation (Fourier's equation) by the
...Finite Difference Method(a time march)
% Numerical scheme used is a first order upwind in time and a second order
...central difference in space (both Implicit and Explicit)
if nargin == 1
    plot_flag = 0;
    video_flag=0;
end
if plot_flag
    figure()
    clf;
end
%% Hi Maya
%Specifying Parameters

nx=1000;               %Number of steps in space(x)
nt=6000;               %Number of time steps 
dt=0.05;              %Width of each time step
t=1:nt;
t = t*dt;
dx=2/(nx-1);         %Width of space step
x=0:dx:2;            %Range of x (0,2) and specifying the grid points
offset = 0;         % starting offset
u=ones(nx,1).*offset;       %Preallocating u
input=zeros(nt, 1);       %Preallocating input
i_loc= round(nx/2);       % input location (center)
un=zeros(nx,1);      %Preallocating un
vis=0.001;            %Diffusion coefficient/viscosity
beta=vis*dt/(dx*dx); %Stability criterion (0<=beta<=0.5, for explicit)
UL=0;                %Left Dirichlet B.C
UR=0;                %Right Dirichlet B.C

% Parameters for binding HaloTag
bound = zeros(nx,1);


%%
%Input: A square wave
k=0;
amount = 15;
init_amount = amount;
out_rate = 1;
in_duration = 1;
sat = 0.5;
for i=2:nt
    if amount > 0
        in1 = in_rate*dt;
        if in1 > amount
            in1 = amount;
        end
        input(i)=input(i-1)+in1 - out_rate*dt;
        amount = amount - in1;
    else
        input(i) = input(i-1) - out_rate*dt;
        if input(i) < 0
            input(i) = 0;
        end
    end
end

%%
%B.C vector
bc=zeros(nx-2,1);
bc(1)=vis*dt*UL/dx^2; bc(nx-2)=vis*dt*UR/dx^2;  %Dirichlet B.Cs
%bc(1)=-UnL*vis*dt/dx; bc(nx-2)=UnR*vis*dt/dx;  %Neumann B.Cs
%Calculating the coefficient matrix for the implicit scheme
E=sparse(2:nx-2,1:nx-3,1,nx-2,nx-2);
A=E+E'-2*speye(nx-2);        %Dirichlet B.Cs
%A(1,1)=-1; A(nx-2,nx-2)=-1; %Neumann B.Cs
D=speye(nx-2)-(vis*dt/dx^2)*A;

%%
%Calculating the velocity profile for each time step
i=2:nx-1;
total_dye = 0;
if video_flag
    myVideo = VideoWriter(['Sim_rate' num2str(in_rate)]); %open video file
    myVideo.FrameRate = 10;  %can adjust this, 5 - 10 works well for me
    open(myVideo)
end
for it=1:nt
    u(i_loc) = u(i_loc) + input(it);
    total_dye = total_dye +input(it);
    u_bound = u;
    u_bound(u_bound > 0.01) = 0.01;
    u_bound(u_bound < 0) = 0;
    u_bound(i_loc) = 0;
    bound = bound + u_bound;
    over_index = bound > sat;
    over = bound(over_index) - sat;
    bound(over_index) = bound(over_index) - over;
    u_bound(over_index) = u_bound(over_index) + over;
    bound(i_loc) = nan;
    u = u - u_bound;
    u(u < 0.001) = 0;
    un=u;
    U=un;U(1)=[];U(end)=[];
    U=U+bc;
    U=D\U;
    u=[UL;U;UR];    
    if mod(it*dt, 1) == 0 && plot_flag
        subplot(1,2,1)
        
        xlim([0.7 1.3]);
        yyaxis left
        h=plot(x,u);       %plotting the velocity profile
        title({['Injection rate =',num2str(in_rate) 'AU/dt'];
            ['time(\itt) = ',num2str(dt*it) 's']})
        xlabel('Spatial co-ordinate (x) \rightarrow')
        ylabel('Unbound dye (AU)')
        drawnow; 
        yyaxis right
        h=plot(x,bound);       %plotting the bound dye
        ylabel('Bound dye (AU)')
        ylim([0 0.6]);
        drawnow;
        subplot(1,2,2)
        plot(t, input)
         title({['Injected dye =',num2str(init_amount)]; 
             ['Total dye = ',num2str(total_dye)]})
        xlabel('Time (s)');
        ylabel('Dye injection (AU');
        vline2(it*dt)
        xlim([0 10]);
        if video_flag
            pause(0.01) %Pause and grab frame
            frame = getframe(gcf); %get frame
            writeVideo(myVideo, frame);
        end
    end
    if sum(u) == 0 && it > 10
        break
    end
end
%%
if plot_flag
    subplot(1,2,1)
    yyaxis left
    h=plot(x,u);       %plotting the velocity profile
    title({['Injection rate =',num2str(in_rate) 'AU/dt'];
    ['time(\itt) = ',num2str(dt*it) 's']})
    xlabel('Spatial co-ordinate (x) \rightarrow')
    ylabel('Unbound dye (AU)')
    drawnow; 
    yyaxis right
    h=plot(x,bound);       %plotting the bound dye
    ylabel('Bound dye (AU)')
    ylim([0 0.6]);
    drawnow;
    subplot(1,2,2)
    plot(t, input)
    title({['Injected dye =',num2str(init_amount)]; 
     ['Total dye = ',num2str(total_dye)]})
    xlabel('Time (s)');
    ylabel('Dye injection (AU');
    vline2(it*dt)
    xlim([0 10]);
    if video_flag
        pause(0.01) %Pause and grab frame
        frame = getframe(gcf); %get frame
        writeVideo(myVideo, frame);
        close(myVideo)
    end
end
start1 = find(bound > 0.01,1);
end1 = find(bound > 0.01,1, 'last');
width = end1 - start1;
if isempty(width)
    width = 0;
end
    