set(gca,'visible','off');
axis('equal')
hold
load en265.001.syn
plot(en265(:,2),en265(:,3),'-');
plot(en265(:,4),en265(:,5),'o');
plot(en265(:,2),en265(:,3),'+');
