% script to create a stereo image pair of points scattered on a sphere,
% rotating. You can cross your eyes to see the 3D image.

N=10000; % no. of points

coords=normrnd(0,1,N,3);
for i=1:size(coords,1)
    coords(i,:)=coords(i,:)/norm(coords(i,:));
end
figure(1)
scatter3(coords(:,1),coords(:,2),coords(:,3),'Marker','.');
axis square

th=-.01;
rot=[ cos(th) 0 -sin(th); 0 1 0; sin(th) 0 cos(th)];
    
for t=1:1000    
    lefteye=[-1,0,-30];
    leftcoords=coords-lefteye;    
    righteye=[1,0,-30];
    rightcoords=coords-righteye;    
    
    figure(2)
    subplot(1,2,2)
    plot(leftcoords(:,1)./leftcoords(:,3),leftcoords(:,2)./leftcoords(:,3), '.','Color','k','MarkerSize',3)
    axis equal
    axis off
    subplot(1,2,1)
    plot(rightcoords(:,1)./rightcoords(:,3),rightcoords(:,2)./rightcoords(:,3), '.','Color','k','MarkerSize',3)
    axis equal
    axis off    
    
    coords=coords*rot;
    drawnow
    
%     figure(1)
%     scatter3(coords(:,1),coords(:,2),coords(:,3),'Marker','.');
%     axis square
end