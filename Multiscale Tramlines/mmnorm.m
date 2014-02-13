function a = mmnorm(b)

m = min(min(b));

a = b - m;

M = max(max(a));

if M > 0
  a = a / M;
end
