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
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

X = [ones(size(X, 1), 1), X];
temp_y = zeros(size(y, 1), num_labels);
for s = 1:size(y, 1),
  temp_y(s, y(s, 1)) = 1;
endfor
y = temp_y;

J = (1 / m) * sum(sum(-y .* log(sigmoid([ones(size(X, 1), 1), sigmoid(X * Theta1')] * Theta2')) - (1 - y) .* log(1 - sigmoid([ones(size(X, 1), 1), sigmoid(X * Theta1')] * Theta2'))));

% parameters regularization
J = J + (lambda / (2 * m)) * (sum(sum(Theta1(:, 2:end) .* Theta1(:, 2:end))) + sum(sum(Theta2(:, 2:end) .* Theta2(:, 2:end))));

Delta1 = zeros(hidden_layer_size, input_layer_size + 1);
Delta2 = zeros(num_labels, hidden_layer_size + 1);

for t = 1:m,
  % feeedforward
  a1 = X(t, :)';                % a1: 401x1
  z2 = Theta1 * a1;        % Theta1: 25x401; z2: 25x1 
  a2 = sigmoid(z2);             % a2: 25x1
  z3 = Theta2 * [1; a2];        % Theta2: 10x26; z3: 10x1
  a3 = sigmoid(z3);             % a3: 10x1
  % backpropagation
  delta3 = a3 - y(t, :)';                            % delta3: 10x1
  delta2 = Theta2(:, 2:end)' * delta3 .* sigmoidGradient(z2);  % delta2: 25x1
  Delta1 = Delta1 .+ delta2 * a1';    % Delta1: 25x401
  Delta2 = Delta2 .+ delta3 * [1; a2]';              % Delta2: 10x26
endfor

Theta1_grad(:, 1) = (1 / m) .* Delta1(:, 1);
Theta1_grad(:, 2:end) = (1 / m) .* Delta1(:, 2:end) .+ (lambda / m) .* Theta1(:, 2:end);
Theta2_grad(:, 1) = (1 / m) .* Delta2(:, 1);
Theta2_grad(:, 2:end) = (1 / m) .* Delta2(:, 2:end) .+ (lambda / m) .* Theta2(:, 2:end);


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
