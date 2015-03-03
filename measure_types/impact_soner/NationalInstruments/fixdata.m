function data=fixdata(data)
data_length=size(data.y,1)-4*51200;
k_actualDataStarts=min(find(data.y(:,3)>0));
k_actualData=(1:data_length)+k_actualDataStarts;
data=data(k_actualData,:);