/*
 * Copyright (c) 2014, Aleksander Osman
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * 
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package ao486.utils;

public class TreePseudoLRU {
    
    static class Node {
        Node(Node l, Node r, int index) {
            this.l = l;
            this.r = r;
            this.index = index;
        }
        
        boolean left;
        int index;
        
        Node l, r;
    }
    
    static int find(Node n) {
        if(n.index != -1) return n.index;
        
        if(n.left) {
            n.left = false;
            return find(n.l);
        }
        else {
            n.left = true;
            return find(n.r);
        }
    }
    
    public static void main(String args[]) throws Exception {
        
        long vals[] = new long[32];
        
        long idx = 0;
        
        for(int i=0; i<vals.length; i++) vals[i] = idx++;
        
        Node n1 = new Node(new Node(null,null, 0), new Node(null,null, 1), -1);
        Node n2 = new Node(new Node(null,null, 2), new Node(null,null, 3), -1);
        Node n3 = new Node(new Node(null,null, 4), new Node(null,null, 5), -1);
        Node n4 = new Node(new Node(null,null, 6), new Node(null,null, 7), -1);
        Node n5 = new Node(new Node(null,null, 8), new Node(null,null, 9), -1);
        Node n6 = new Node(new Node(null,null, 10), new Node(null,null, 11), -1);
        Node n7 = new Node(new Node(null,null, 12), new Node(null,null, 13), -1);
        Node n8 = new Node(new Node(null,null, 14), new Node(null,null, 15), -1);
        Node n9 = new Node(new Node(null,null, 16), new Node(null,null, 17), -1);
        Node n10 = new Node(new Node(null,null, 18), new Node(null,null, 19), -1);
        Node n11 = new Node(new Node(null,null, 20), new Node(null,null, 21), -1);
        Node n12 = new Node(new Node(null,null, 22), new Node(null,null, 23), -1);
        Node n13 = new Node(new Node(null,null, 24), new Node(null,null, 25), -1);
        Node n14 = new Node(new Node(null,null, 26), new Node(null,null, 27), -1);
        Node n15 = new Node(new Node(null,null, 28), new Node(null,null, 29), -1);
        Node n16 = new Node(new Node(null,null, 30), new Node(null,null, 31), -1);
        
        Node m1 = new Node(n1,n2, -1);
        Node m2 = new Node(n3,n4, -1);
        Node m3 = new Node(n5,n6, -1);
        Node m4 = new Node(n7,n8, -1);
        Node m5 = new Node(n9,n10, -1);
        Node m6 = new Node(n11,n12, -1);
        Node m7 = new Node(n13,n14, -1);
        Node m8 = new Node(n15,n16, -1);
        
        Node o1 = new Node(m1,m2, -1);
        Node o2 = new Node(m3,m4, -1);
        Node o3 = new Node(m5,m6, -1);
        Node o4 = new Node(m7,m8, -1);
        
        Node p1 = new Node(o1,o2, -1);
        Node p2 = new Node(o3,o4, -1);
        
        Node q1 = new Node(p1,p2, -1);
        
        int found = 0;
        int count = 10000;
        for(int i=0; i<count; i++) {
            // find minimal
            long min = Long.MAX_VALUE;
            for(int j=0; j<vals.length; j++) if(vals[j] < min) min = vals[j];
            
            int index = find(q1);
            if(vals[index] == min) found++;
            
            vals[index] = idx++;
        }
        
        System.out.println((double)found / (double)count);
    }
    
}
