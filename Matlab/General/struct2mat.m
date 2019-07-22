function [x,n]= struct2mat(S)
%STRUCT2MAT	Converts a structure into a matrix.
%	[X,n]= STRUCT2MAT(S) converts a structre S into a numeric matrix X. The 
%	contents of each *numeric* field of S (either a vector or a matrix) will 
%	form 1 column of X. Fieldnames are returned in cell array 'n'. If the 
%	fields of S aren't of the same length, the columns of X will be padded 
%	with NaN.
%	Example:
%	s= struct('a',['string of letters'],'b',[1 2; 3 4],'c',[1 2 3 4 5 6 7 8 9])
%	[x,n]= struct2mat(s)
%	Author: F. de Castro

% Extract field names
fn= fieldnames(S);

% Identify numeric & find out maximum length
len=   zeros(1,numel(fn));
isnum= zeros(1,numel(fn));
maxlen= 0;
for j= 1:numel(fn)
	if isnumeric(S.(fn{j})) 
		isnum(j)= j;
		len(j)= numel(S.(fn{j}));
		if len(j) > maxlen, maxlen= numel(S.(fn{j})); end
	end
end
isnum= isnum(isnum~=0);
ncol= numel(isnum);

% Preallocation
x= NaN(maxlen, ncol);
n= cell(ncol,1);

% Take numeric fields and field names
for j= 1:ncol
	x(1:len(isnum(j)),j)= S.(fn{isnum(j)})(:);
	n(j)= {fn{isnum(j)}};
end

