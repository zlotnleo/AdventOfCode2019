#include <iostream>
#include <fstream>
#include <string>
#include <map>
#include <list>
#include <stack>
#include <algorithm>
#include <set>
#include <vector>

using namespace std;

class Day6
{
private:
    map<string, set<string> *> *graph;
    set<string> *allObjects;

public:
    Day6(fstream &f)
    {
        graph = new map<string, set<string> *>();
        allObjects = new set<string>();

        string line;
        while (getline(f, line))
        {
            int pos = line.find(')');
            string centre = line.substr(0, pos);
            string object = line.substr(pos + 1);

            allObjects->insert(centre);
            allObjects->insert(object);

            auto from = graph->find(centre);
            if (from == graph->end())
            {
                auto tos = new set<string>();
                tos->insert(object);
                (*graph)[centre] = tos;
            }
            else
            {
                from->second->insert(object);
            }
        }
    }

    ~Day6()
    {
        delete allObjects;
        for_each(graph->begin(), graph->end(), [](pair<string, set<string> *> p) { delete p.second; });
        delete graph;
    }

    int count_orbits()
    {
        return count_orbits("COM").second;
    }

    int count_hops_to_santa()
    {
        auto v1 = path_between("COM", "YOU");
        auto v2 = path_between("COM", "SAN");
        bool fail = false;
        int result;
        if (!v1 || !v2)
        {
            fail = true;
        }
        else
        {
            vector<string>::iterator i1, i2;
            for (i1 = v1->begin(), i2 = v2->begin(); i1 != v1->end() && i2 != v2->end() && *i1 == *i2; ++i1, ++i2)
                ;
            if (i1 == v1->end() || i2 == v2->end())
            {
                fail = true;
            }
            else
            {
                int count1, count2;
                for (count1 = 0; i1 != v1->end(); ++i1, ++count1)
                    ;
                for (count2 = 0; i2 != v2->end(); ++i2, ++count2)
                    ;
                result = count1 + count2 - 2;
            }
        }

        delete v1;
        delete v2;
        if (fail)
        {
            return -1;
        }
        return result;
    }

private:
    pair<int, int> count_orbits(string root)
    {
        auto fromRoot = graph->find(root);
        pair<int, int> result = {1, 0};
        if (fromRoot == graph->end())
        {
            return result;
        }
        for (auto to : *(fromRoot->second))
        {
            auto cur = count_orbits(to);
            result.first += cur.first;
            result.second += cur.first + cur.second;
        }
        return result;
    }

    vector<string> *path_between(string from, string to)
    {
        if (from == to)
        {
            return new vector<string>{from};
        }
        auto directFrom = graph->find(from);
        if (directFrom == graph->end())
        {
            return nullptr;
        }
        for (auto directTo : *(directFrom->second))
        {
            auto v = path_between(directTo, to);
            if (v)
            {
                v->insert(v->begin(), from);
                return v;
            }
        }
        return nullptr;
    }
};

int main()
{
    fstream f;
    f.open("input.txt");
    auto graph = new Day6(f);
    f.close();

    cout << graph->count_orbits() << endl;
    cout << graph->count_hops_to_santa() << endl;

    delete graph;
    return 0;
}