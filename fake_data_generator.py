import random
import time
    
def str_time_prop(start, end, time_format, prop):
    """Get a time at a proportion of a range of two formatted times.

    start and end should be strings specifying times formatted in the
    given format (strftime-style), giving an interval [start, end].
    prop specifies how a proportion of the interval to be taken after
    start.  The returned time will be in the specified format.
    """

    stime = time.mktime(time.strptime(start, time_format))
    etime = time.mktime(time.strptime(end, time_format))

    ptime = stime + prop * (etime - stime)

    return time.strftime(time_format, time.localtime(ptime))


def random_date(start, end, prop):
    return str_time_prop(start, end, '%Y-%m-%d %H:%M:%S', prop)




tup_set = set()
s = ""

for i in range(100000):
    r_date = random_date("2020-1-1 00:00:00", "2022-12-1 00:00:00", random.random())
    id = random.randint(0, 99)
    tuple = (id, r_date)
    
    if tuple not in tup_set:
        q = f"""\ninsert into sales (user_id, transaction_date, item_number, produce_id, sale_price, weight) values
        ({tuple[0]},
        '{tuple[1]}',
        {random.randint(0, 30)},
        {random.randint(1, 4)},
        {round(random.uniform(10.50, 50.50), 2)},
        {random.randint(100, 10000)});
        """
    
    
        s += q

print(s)
        
        

with open('fake_insert.txt', 'w') as f:
    f.write(s)