//STL can merge lists in O(1)

std::list<int> l1 = create();
std::list<int> l2 = create();
l1.splice(l1.end(), l2);

//Note that this empties l2 and moves its elements to l1.


