function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m

% Calculate h(x) in the neural network model
a1 = [ones(m,1) X];
z2 = a1 * Theta1';
a2 = sigmoid(z2);
a2_0 = ones(size(a2,1),1);  % creating a column of ones for a2
a2 = [a2_0 a2];
z3 = a2 * Theta2';
a3 = sigmoid(z3);
h = a3; % a3 = h(x)

% The vector y passed into the function is a vector of labels
% containing values from 1..K. You need to map this vector into a 
% binary vector of 1's and 0's to be used with the neural network
% cost function.
y = dummyvar(y);

% Calculate cost J without regularization
% Since y is a vector of categorical variables, we compute the dot product
% of y with h
J = 1/m * sum(sum( -y.*log(h) - (1-y).*log(1-h)));


% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.

for t=1:m % where t is a training example
    
    % 1) Forward propagation
    a1 = [1 X(t,:)];
    z2 = a1 * Theta1';
    a2 = sigmoid(z2);
    a2 = [1 a2];
    z3 = a2 * Theta2';
    a3 = sigmoid(z3);
    h = a3; 
    % 2) Calculate delta in layer 3
    d3 = a3 - y(t,:)
    % 3) Calculate delta in layer 2
    d2 = d3 * Theta2 .* sigmoidGradient([1 z2])
    d2 = d2(2:end)
    % 4) Calculate Theta_grad
    Theta1_grad = Theta1_grad + d2' * a1;
    Theta2_grad = Theta2_grad + d3' * a2;
end

Theta1_grad = 1/m*Theta1_grad
Theta2_grad = 1/m*Theta2_grad 
    
    
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% Adding the regularization term:
% We do not regularize x_0
regTheta1 = Theta1(:,2:end);
regTheta2 = Theta2(:,2:end);
% combine thetas (without order) for easy calculation of cost
regTheta = [regTheta1(:); regTheta2(:)];
J = J + lambda / (2*m) * sum(regTheta.^2);


% Regularizing Gradient
Theta1_grad_0 = Theta1_grad(:,1)
Theta1_grad = Theta1_grad(:,2:end) + lambda/m * regTheta1
Theta1_grad = [Theta1_grad_0 Theta1_grad]

Theta2_grad_0 = Theta2_grad(:,1)
Theta2_grad = Theta2_grad(:,2:end) + lambda/m * regTheta2
Theta2_grad = [Theta2_grad_0 Theta2_grad]


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
