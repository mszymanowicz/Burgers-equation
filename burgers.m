clear;
clf;
%Spytaj uzytkownika o dane
D=input('Podaj wartosc dyssypacji (w okolicach 0.01): D= ');
fprintf('Dopasuj wartosci interwalow dt i dx tak, aby C=u*(dt/dx)<1, wtedy metoda maccormacka przewaznie jest stabilna\n');
choice=input('Jesli chcesz podac ilosci wezlow i krokow czasowych wcisnij 1, jesli chcesz podac ich interwaly wcisnij 2, zakonczenie programu wcisnij 0\n');
bol=1;
while bol==1
    if (choice==1)
        T=input('Podaj calkowity czas T [sek]: ');
        Nx=input('Podaj ilosc wezlow x: ');
        Nt=input('Podaj ilosc krokow czasowych t: ');
        dx=1./(Nx-1);
        dt=T./(Nt-1);
    elseif (choice==2)
        T=input('Podaj calkowity czas T [sek]: ');
        dx=input('Podaj interwal miedzy wezlami z przedzialu (0,1): ');
        dt=input('Podaj interwal kroku czasowego z przedzialu (0, T): ');
    elseif (choice==0)
        return
    else
        fprintf('Wcisnij 1 lub 2');
        continue;
    end
    bol=0;
    wsk=dt/dx;
    if (wsk>=1)
        choice=input('dobrano dt/dx tak, ze metoda moze byc niestabilna. Jesli chcesz policzyc wcisnij 1, jesli chcesz wprowadzic dane ponownie wcisnij 2: ');
        if (choice==1)
            bol=0;
        elseif(choice==2)
            bol=1;
        else
            return
        end
    end
end

%---u0(x)+MacCormack--- 
x=[0:dx:1];
t=[0:dt:T];
n=1;
u=zeros(length(x),length(t));
upr=zeros(length(x),length(t)-1);
for j=1:length(x)  %dla n=1 czyli t=0
    if ((x(j)>=0) && (x(j)<=0.25))
        u(j,n)=0;
    elseif ((x(j)>0.25) && (x(j)<=0.5))
        u(j,n)=4*x(j)-1;
    elseif ((x(j)>0.5) && (x(j)<=0.75))
        u(j,n)=-4*x(j)+3;
    elseif ((x(j)>0.75) && (x(j)<=1))
        u(j,n)=0;
    end
end


for n=1:(length(t)-1)
    for j=1:length(x)
        r=D*(dt/(dx*dx));
        if (j==1)  %j-1 --> length(x) zamien 0wy element na nty
            upr(j,n)=u(j,n)-(dt/dx)*(0.5*u(j+1,n)*u(j+1,n)-0.5*u(j,n)*u(j,n))+r*(u(j+1,n)-2*u(j,n)+u(length(x),n));
        elseif (j==length(x)) %j+1 -->1 zamien n+1y element na 1szy
            upr(j,n)=u(j,n)-(dt/dx)*(0.5*u(1,n)*u(1,n)-0.5*u(j,n)*u(j,n))+r*(u(1,n)-2*u(j,n)+u(j-1,n)); % z u(..,n) licze predyktor
        else
            upr(j,n)=u(j,n)-(dt/dx)*(0.5*u(j+1,n)*u(j+1,n)-0.5*u(j,n)*u(j,n))+r*(u(j+1,n)-2*u(j,n)+u(j-1,n)); % z u(..,n) licze predyktor
        end    
    end
    for j=1:length(x)
         if (j==1)
            u(j,n+1)=0.5*(u(j,n)+upr(j,n)-(dt/dx)*(0.5*upr(j,n)*upr(j,n)-0.5*upr(length(x),n)*upr(length(x),n))+r*(upr(j+1,n)-2*upr(j,n)+upr(length(x),n)));
         elseif (j==length(x))
             u(j,n+1)=0.5*(u(j,n)+upr(j,n)-(dt/dx)*(0.5*upr(j,n)*upr(j,n)-0.5*upr(j-1,n)*upr(j-1,n))+r*(upr(1,n)-2*upr(j,n)+upr(j-1,n))); 
        else
            u(j,n+1)=0.5*(u(j,n)+upr(j,n)-(dt/dx)*(0.5*upr(j,n)*upr(j,n)-0.5*upr(j-1,n)*upr(j-1,n))+r*(upr(j+1,n)-2*upr(j,n)+upr(j-1,n))); % z upr(..,n) licze korektor u(..,n+1)
         end
    end
end

%Stworz plik .avi, zapisz do niego serie wykresow o framerate=...
for i=1:length(t)
    clf;
    v=u(:,i);
    plot(x,v);
    axis([0,1,0,1.3])
    str='time: '+compose("%.3f",t(i)) +' s';
    title([str]);
    xlabel('x[*L]');
    ylabel('u(x,t)');
    F(i)=getframe(gcf);
end
writerObj=VideoWriter('test1.avi');
writerObj.FrameRate = 150;
open(writerObj);
for i=1:length(t)
    writeVideo(writerObj, F(i));
end
close(writerObj);
    
%end
       

