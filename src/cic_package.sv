package cic_package;
/*********************************************************************************************/
function longint nchoosek;
    input   longint n;
    input   longint k;
    longint tmp;
    longint i;
    begin
        tmp = 1.0;
        for (i=1;i<=(n-k);i++)
            tmp = tmp*(k+i)/i;
        nchoosek = tmp;
    end
endfunction
/*********************************************************************************************/
function longint clog2_l;
    input longint depth;
    longint i;
    begin
         i = depth;        
        for(clog2_l = 0; i > 0; clog2_l = clog2_l + 1)
            i = i >> 1;
    end
endfunction
/*********************************************************************************************/
function longint h;
    input   longint j;
    input   longint k;
    input   longint R;
    input   longint M;
    input   longint N;
    longint c_stop;
    longint i;
    longint tmp;
    begin
        c_stop = k/(R*M);
        if ((j>=1)&&(j<=N)) begin
            tmp=0.0;
            for (i=0;i<=c_stop;i++) begin
                if (i%2)
                    tmp = tmp - nchoosek(N,i)*nchoosek(N-j+k-R*M*i,k-R*M*i);
                else
                    tmp = tmp + nchoosek(N,i)*nchoosek(N-j+k-R*M*i,k-R*M*i);
            end
        end
        else begin
            tmp = nchoosek(2*N+1-j,k);
            if (k%2)
                tmp = -tmp;
        end
        h = tmp;
    end
endfunction
/*********************************************************************************************/
function longint F;
    input   longint j;
    input   longint R;
    input   longint G;
    input   longint M;
    longint c_stop;
    longint tmp;
    longint i;
    begin
        tmp = 0.0;
        if (j<=M)
            c_stop=(((R*G-1)*M)+j-1);
        else
            c_stop=2*M+1-j;
        for (i=0;i<=c_stop;i++) begin
            tmp = tmp + h(j,i,R,G,M)*h(j,i,R,G,M);
        end
        F = tmp;
    end
endfunction
/*********************************************************************************************/
function integer B;
    input   longint j;
    input   longint R;
    input   longint G;
    input   longint M;
    input   longint dw_in;
    input   longint dw_out;
    longint B_max;
    longint sigma_T;
    longint tmp;
    begin
        B_max = $clog2((R*G)**M)+dw_in-1;
        sigma_T = (2**(2*(B_max-dw_out+1)))/12;
        tmp = (6*sigma_T)/(M*F(j,R,G,M));
        B = (clog2_l(tmp)-1)/2;
    end
endfunction
/*********************************************************************************************/
endpackage
