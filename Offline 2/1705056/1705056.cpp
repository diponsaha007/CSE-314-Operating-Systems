#include<iostream>
#include<pthread.h>
#include<semaphore.h>
#include<queue>
#include<unistd.h>
#include<random>
#include<chrono>
#include<map>

using namespace std;

mt19937 rng(chrono::steady_clock::now().time_since_epoch().count());

int get_random(int a, int b) {
    int x = uniform_int_distribution<int>(a, b)(rng);
    return x;
}

class Passenger {
public:
    int pid;
    bool vip;

    string show() const {
        string ret = "Passenger " + to_string(pid);
        if (vip) {
            ret += " (VIP)";
        }
        ret += " ";
        return ret;
    }
};


int n, m, p;
int w, x, y, z;

chrono::time_point<chrono::system_clock> start;


map<int, Passenger> mp;
sem_t kiosk;
sem_t binary_sem;
sem_t boarding;
sem_t special_kiosk;
queue<int> available_kiosks;
int passenger_id = 1;

int get_time() {
    auto finish = chrono::high_resolution_clock::now();
    chrono::duration<double, milli> elapsed = finish - start;
    return (int) round(elapsed.count() / 1e3);
}

class Security_check {
public:
    sem_t belt;
    int belt_id;

    void init(int p, int id) {
        sem_init(&belt, 0, p);
        belt_id = id;
    }

    void check_in(Passenger &passenger) {
        sem_wait(&binary_sem);
        cout << passenger.show() << "has started waiting for security check in belt " << belt_id << " from time "
             << get_time() << "\n";
        sem_post(&binary_sem);

        sem_wait(&belt);

        sem_wait(&binary_sem);
        cout << passenger.show() << "has started the security check at time " << get_time() << "\n";
        sem_post(&binary_sem);

        sleep(x);

        sem_wait(&binary_sem);
        cout << passenger.show() << "has crossed the security check at time " << get_time() << "\n";
        sem_post(&binary_sem);

        sem_post(&belt);
    }

    ~Security_check() {
        sem_destroy(&belt);
    }
};

class VIP_channel {
public:
    pthread_mutex_t mutex;
    pthread_cond_t cond[2];
    vector<int> waiting;
    int curr_dir; //0 --> left to right ,,, 1--> right to left
    int currently_walking;

    VIP_channel() {
        pthread_mutex_init(&mutex, 0);
        pthread_cond_init(&cond[0], 0);
        pthread_cond_init(&cond[1], 0);
        curr_dir = 0;
        waiting.resize(2, 0);
        currently_walking = 0;
    }


    void vip_channel(Passenger &passenger, int dir) {
        string s = (dir == 0 ? "from left to right" : "from right to left");
        sem_wait(&binary_sem);
        cout << passenger.show() << "is waiting to walk in VIP Channel " << s << " at time "
             << get_time() << "\n";
        sem_post(&binary_sem);

        if (dir == 1) {

            pthread_mutex_lock(&mutex);
            while (!((curr_dir == dir && waiting[1 - dir] == 0) ||
                     (curr_dir != dir && currently_walking == 0 && waiting[1 - dir] == 0))) {
                waiting[dir]++;
                pthread_cond_wait(&cond[1], &mutex);
                waiting[dir]--;
            }
            pthread_mutex_unlock(&mutex);

            sem_wait(&binary_sem);
            cout << passenger.show() << "has started walking in VIP Channel " << s << " at time "
                 << get_time() << "\n";
            sem_post(&binary_sem);

            curr_dir = dir;
            currently_walking++;
            sleep(z);


            sem_wait(&binary_sem);
            cout << passenger.show() << "has finished walking in VIP Channel " << s << " at time "
                 << get_time() << "\n";
            sem_post(&binary_sem);

            pthread_mutex_lock(&mutex);
            currently_walking--;
            if (dir == curr_dir && currently_walking == 0 && waiting[1 - dir] > 0) {
                pthread_cond_broadcast(&cond[0]);
            }
            pthread_mutex_unlock(&mutex);
        } else {
            pthread_mutex_lock(&mutex);
            while (!(curr_dir == dir || (curr_dir != dir && currently_walking == 0))) {
                waiting[dir]++;
                pthread_cond_wait(&cond[0], &mutex);
                waiting[dir]--;
            }
            pthread_mutex_unlock(&mutex);

            curr_dir = dir;
            currently_walking++;

            sem_wait(&binary_sem);
            cout << passenger.show() << "has started walking in VIP Channel " << s << " at time "
                 << get_time() << "\n";
            sem_post(&binary_sem);


            sleep(z);

            sem_wait(&binary_sem);
            cout << passenger.show() << "has finished walking in VIP Channel " << s << " at time "
                 << get_time() << "\n";
            sem_post(&binary_sem);

            pthread_mutex_lock(&mutex);
            currently_walking--;
            if (dir == curr_dir && currently_walking == 0 && waiting[1 - dir] > 0) {
                pthread_cond_broadcast(&cond[1]);
            }
            pthread_mutex_unlock(&mutex);
        }

    }

    ~VIP_channel() {
        pthread_cond_destroy(&cond[0]);
        pthread_cond_destroy(&cond[1]);
        pthread_mutex_destroy(&mutex);
    }
};

VIP_channel vipChannel;
vector<Security_check> belts;

void self_check_in(Passenger &passenger) {
    sem_wait(&kiosk);

    //get a kiosk
    sem_wait(&binary_sem);
    int kiosk_id = available_kiosks.front();
    available_kiosks.pop();
    cout << passenger.show() << "has started self-check in at kiosk " << kiosk_id << " at time " << get_time()
         << "\n";
    sem_post(&binary_sem);

    sleep(w);

    //put that back in queue
    sem_wait(&binary_sem);
    cout << passenger.show() << "has finished self-check in at time " << get_time() << "\n";
    available_kiosks.push(kiosk_id);
    sem_post(&binary_sem);

    sem_post(&kiosk);
}

void boarding_pass(Passenger &passenger, bool lost_boarding_pass) {
    sem_wait(&binary_sem);
    cout << passenger.show() << "started waiting to be boarded at time "
         << get_time() << "\n";
    sem_post(&binary_sem);

    sem_wait(&boarding);

    sem_wait(&binary_sem);
    cout << passenger.show() << "has started boarding the plane at time " << get_time() << "\n";
    sem_post(&binary_sem);

    if (!lost_boarding_pass) {
        sleep(y);
        sem_wait(&binary_sem);
        cout << passenger.show() << "has boarded the plane at time " << get_time() << "\n";
        sem_post(&binary_sem);
    } else {
        sem_wait(&binary_sem);
        cout << passenger.show()
             << "has lost the boarding pass. Sending back to special kiosk using the VIP channel\n";
        sem_post(&binary_sem);
    }

    sem_post(&boarding);

}

void special_kiosk_check_in(Passenger &passenger) {
    sem_wait(&special_kiosk);
    //get a kiosk
    sem_wait(&binary_sem);
    cout << passenger.show() << "has started self-check in at special kiosk at time " << get_time() << "\n";
    sem_post(&binary_sem);

    sleep(w);

    //put that back in queue
    sem_wait(&binary_sem);
    cout << passenger.show() << "has finished self-check at time " << get_time() << "\n";
    sem_post(&binary_sem);

    sem_post(&special_kiosk);

}

sem_t passenger_sem;

void *arrive(void *arg) {
    int *pid;
    pid = (int *) arg;
    Passenger passenger = mp[*pid];
    sem_post(&passenger_sem);
    sem_wait(&binary_sem);
    cout << passenger.show() << "has arrived at the airport at time " << get_time() << "\n";
    sem_post(&binary_sem);
    self_check_in(passenger);
    if (!passenger.vip) {
        int idx = get_random(0, n - 1);
        belts[idx].check_in(passenger);
    } else {
        vipChannel.vip_channel(passenger, 0);
    }
    int val = get_random(1, 10);
    bool lost = (val <= 3);
    boarding_pass(passenger, lost);
    if (lost) {
        vipChannel.vip_channel(passenger, 1);
        special_kiosk_check_in(passenger);
        vipChannel.vip_channel(passenger, 0);
        boarding_pass(passenger, false);
    }
    return NULL;
}


void generate_passenger(Passenger &passenger) {
    passenger.pid = passenger_id;
    passenger_id++;
    int r = get_random(1, 3);
    passenger.vip = (r == 3);
}

void add_passengers() {
    const int MEAN = 5;
    const int ARRIVAL_RATE = 6;
    const int REPEAT = 1;

    vector<pthread_t> all;
    Passenger pr;


    for (int rep = 0; rep < REPEAT; rep++) {
        poisson_distribution<int> distribution(MEAN);
        vector<int> cnt(10, 0);
        for (int i = 0; i < ARRIVAL_RATE; i++) {
            int number = distribution(rng);
            while (number >= (int) cnt.size()) {
                number = distribution(rng);
            }
            cnt[number]++;
        }
        for (int i: cnt) {
            for (int j = 0; j < i; j++) {
                generate_passenger(pr);
                mp[pr.pid] = pr;
                pthread_t arrive_thread;
                pthread_create(&arrive_thread, NULL, arrive, (void *) &pr.pid);
                sem_wait(&passenger_sem);
                all.push_back(arrive_thread);
            }
            sleep(1);
        }
        sleep(5);
    }
    for (int i = 0; i < all.size(); i++) {
        pthread_join(all[i], 0);
    }
}

int main() {
    cin >> m >> n >> p >> w >> x >> y >> z;
    for (int i = 1; i <= m; i++) {
        available_kiosks.push(i);
    }

    belts.resize(n);
    for (int i = 0; i < n; i++) {
        belts[i].init(p, i + 1);
    }
    sem_init(&kiosk, 0, m);
    sem_init(&binary_sem, 0, 1);
    sem_init(&boarding, 0, 1);
    sem_init(&special_kiosk, 0, 1);
    sem_init(&passenger_sem, 0, 0);
    start = chrono::high_resolution_clock::now();

    add_passengers();

    sem_destroy(&kiosk);
    sem_destroy(&binary_sem);
    sem_destroy(&boarding);
    sem_destroy(&special_kiosk);
    sem_destroy(&passenger_sem);

    return 0;
}
