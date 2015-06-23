/l\.sf/ { 
            flag = 1 
            next 
        }

        { 
            if (flag) {
                flag = 0;
                print
            }
        }
