//compare two large fractions
//a,b,c,d can be 1e16
//complexity O(log n)

bool comp(ll a, ll b, ll c, ll d){
  if(a / b != c / d) return a / b < c / d;
  a %= b, c %= d;
  if(c == 0) return 0;
  if(a == 0) return 1;
  return comp(d, c, b, a);
}
