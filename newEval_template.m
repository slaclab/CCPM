function err = newEval_template(this) % Accepts the object, returns the error

% Setup the proper output variable
err = zeros(this.herd_numHerd,2);
err(:,1) = 1:this.herd_numHerd; % first column is just the numbering of the herd

for ii = 1:this.herd_numHerd
    
    % the second column is just the error for whatever comparison you want
    err(ii,2) = 1/someComparisson(...
        this.sol_Image,... % usually has the solution image...
        abs(this.herd(ii).field_fList).^2/max(max(abs(this.herd(ii).field_fList).^2)) ... % ... and the normalized herd generated result
        );
    
end

end

function val = someComparisson(im1,im2) % fill this with the comparison function

val = (im1 - im2);

end