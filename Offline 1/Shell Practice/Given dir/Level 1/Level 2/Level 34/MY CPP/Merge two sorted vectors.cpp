#include <bits/stdc++.h>
//#include <ext/pb_ds/assoc_container.hpp>
//using namespace __gnu_pbds;
using namespace std;
typedef  long long ll;
//typedef tree<int,null_type,less<int >,rb_tree_tag,tree_order_statistics_node_update>indexed_set;
template<class T1, class T2>
ostream &operator <<(ostream &os, pair<T1,T2>&pii);
template <class T>
ostream &operator <<(ostream &os, vector<T>&v);
template <class T>
ostream &operator <<(ostream &os, set<T>&v);
#define debug(a) cout<<#a<<" --> "<<(a)<<endl;
#define fastInput ios_base::sync_with_stdio(false);cin.tie(0)
#define INPUT freopen("input.txt","r",stdin)
#define OUTPUT freopen("output.txt","w",stdout)
#define Error  1e-9
#define pi (2*acos(0))
const ll mod = 1000000007;
const int N = 2e5+5;


void Solve(int cas)
{
    vector<int>a={1,4,6,9};
    vector<int>b={2,3,4,5};
    vector<int>c;
    merge(a.begin(), a.end(),
          b.begin(), b.end(),
          back_inserter(c));
    cout<<c<<endl;

}


int main()
{
    //fastInput;
    //cout.tie(0);
    //OUTPUT;

    int t=1,cas=0;
    //scanf("%d",&t);
    while(t--)
    {
        Solve(++cas);
    }
    return 0;
}
/*

*/


//os.order_of_key(v): returns how many elements strictly less than v
//os.find_by_order()

template<class T1, class T2>
ostream &operator <<(ostream &os, pair<T1,T2>&pii)
{
    os<<"{"<<pii.first<<", "<<pii.second<<"} ";
    return os;
}
template <class T>
ostream &operator <<(ostream &os, vector<T>&v)
{
    //os<<"[ ";
    for(int i=0; i<v.size(); i++)
    {
        os<<v[i]<<" " ;
    }
    //os<<" ]";
    return os;
}
template <class T>
ostream &operator <<(ostream &os, set<T>&v)
{
    os<<"[ ";
    for(T i:v)
    {
        os<<i<<" ";
    }
    os<<" ]";
    return os;
}
