function C = xcovMat(A,B)
% cross covariance between two matrices (vectors) with rows containing
% variables and columns observations

if size(A,2) ~= size(B,2)
    error('A and B must have equal observations');
end

P = size(A,2);

C = zeros(size(A,1),size(B,1));
for i = 1:size(A,1)
    ui = mean(A(i,:));
    for j = 1:size(B,1)
        uj = mean(B(j,:));
        C(i,j) = sum((A(i,:)-ui).*conj(B(j,:)-uj))/(P-1);
        
        % same as D=cov(A(i,:),B(j,:)); C(i,j)=D(1,2);
    end
end

end