
module pwm12_8s ( pwmOut, dataIn, selectCR, write, reset, pwmClk, syncIn );
input  [31:0] dataIn;
input  [7:0] syncIn;
input  selectCR, write, reset, pwmClk;
output pwmOut;
    wire \clkCount[5] , \timerHighData[1] , \randomData[6] , 
        \timerHighData[8] , \timerHighData[5] , \clkCount[1] , \syncSource[2] , 
        load4PDM, \randomData[9] , \clkCount[3] , \timerHighData[7] , 
        \syncSource[0] , \shadowclkPreScale[0] , \clkPreScale[1] , preScaleClk, 
        pwModeOut, syncPolarity, pdmLess, \counter12[11] , \timerHighData[3] , 
        \timerLowData[6] , \timerLowData[10] , \counter12[3] , 
        \timerLowData[2] , \clkCount200[3] , \randomData[11] , \counter12[7] , 
        \State[0] , \State[2] , \shadowSyncSource[1] , \timerLowData[9] , 
        \counter12[5] , \clkCount200[1] , \timerLowData[0] , extSync, loadHigh, 
        \mode[0] , shadowSyncPolarity, \counter12[1] , \timerHighData[11] , 
        \counter12[8] , \timerLowData[4] , \clkCount200[5] , 
        \timerHighData[10] , \counter12[0] , \counter12[9] , \clkCount200[4] , 
        \timerLowData[5] , \shadowSyncSource[0] , \timerLowData[8] , 
        \counter12[4] , \timerLowData[1] , \clkCount200[0] , pdModeOut, 
        \mode[1] , \timerLowData[3] , \randomData[10] , \clkCount200[2] , 
        \shadowSyncSource[2] , \counter12[6] , \State[1] , \timerLowData[7] , 
        \timerLowData[11] , \counter12[2] , \clkPreScale[0] , shift, 
        extSyncRst, \counter12[10] , \timerHighData[2] , \randomData[8] , 
        writeCR, \syncSource[1] , \timerHighData[6] , \clkCount[2] , loadLow, 
        \shadowclkPreScale[1] , syncPulse, \clkCount[0] , \timerHighData[4] , 
        \timerHighData[0] , \clkCount[4] , \randomData[7] , \timerHighData[9] , 
        n618, n619, n702, n703, n704, n705, n706, n707, n708, n709, n710, n711, 
        n712, n713, n714, n715, n716, n717, n718, n719, n720, n721, n722, n723, 
        n724, n725, n726, n727, n728, n729, n730, n731, n732, n733, n734, n735, 
        n736, n737, n738, n739, n740, n741, n742, n743, n744, n745, n746, n747, 
        n748, n749, n750, n751, n752, n753, n754, n755, n756, n757, n758, n759, 
        n760, n761, n762, n763, n764, n765, n766, n767, n768, n769, n770, n771, 
        n772, n773, n774, n775, n776, n777, n778, n779, n780, n781, n782, n783, 
        n784, n785, n786, n787, n788, n789, n790, n791, n792, n793, n794, n795, 
        n796, n797, n798, n799, n800, n801, n802, n803, n804, n805, n806, n807, 
        n808, n809, n810, n811, n812, n813, n814, n815, n816, n817, n818, n819, 
        n820, n821, n822, n823, n824, n825, n826, n827, n828, n829, n830, n831, 
        n832, n833, n834, n835, n836, n837, n838, n839, n840, n841, n842, n843, 
        n844, n845, n846, n847, n848, n849, n850, n851, n852, n853, n854, n855, 
        n856, n857, n858, n859, n860, n861, n862, n863, n864, n865, n866, n867, 
        n868, n869, n870, n871, n872, n873, n874, n875, n876, n877, n878, n879, 
        n880, n881, n882, n883, n884, n885, n886, n887, n888, n889, n890, n891, 
        n892, n893, n894, n895, n896, n897, n898, n899, n900, n901, n902, n903, 
        n904, n905, n906, n907, n908, n909, n910, n911, n912, n913, n914, n915, 
        n916, n917, n918, n919, n920, n921, n922, n923, n924, n925, n926, n927, 
        n928, n929, n930, n931, n932, n933, n934, n935, n936, n937, n938, n939, 
        n940, n941, n942, n943, n944, n945, n946, n947, n948, n949, n950, n951, 
        n952, n953, n954, n955, n956, n957, n958, n959, n960, n961, n962, n963, 
        n964, n965, n966, n967, n968, n969, n970, n971, n972, n973, n974, n975, 
        n976, n977, n978, n979, n980, n981, n982, n983, n984, n985, n986, n987, 
        n988, n989, n990, n991, n992, n993, n994, n995, n996, n997, n998, n999, 
        n1000, n1001, n1002, n1003, n1004, n1005;
    GTECH_ZERO U321 ( .Z(n1005) );
    assign n619 = ~pwmClk;
    assign n702 = ~n703;
    assign n1004 = (~n704 & ~n705 & ~n706);
    assign n1003 = ~n707;
    assign n1002 = ~n708;
    assign n1001 = (~n709 & ~n710);
    assign n1000 = ~shift;
    assign n999 = (~n711 & ~n712);
    assign n998 = (~\State[2]  & ~n713 & ~n714);
    assign n997 = ~n715;
    assign n996 = ~n716;
    assign n995 = ~n717;
    assign n994 = ~n718;
    assign n993 = ~n719;
    assign n992 = ~n720;
    assign n991 = ~n721;
    assign n990 = ~n722;
    assign n989 = ~n723;
    assign n988 = ~n724;
    assign n987 = ~n725;
    assign n986 = ~n726;
    assign n985 = ~n727;
    assign n984 = ~n728;
    assign n983 = ~n729;
    assign extSyncRst = ~n730;
    assign writeCR = (~n731 & ~n732);
    assign pwmOut = ~n733;
    assign n734 = ~n735;
    assign n736 = ~n737;
    assign n738 = ~n739;
    assign n740 = ~n741;
    assign n742 = (~n1000 & ~n703);
    assign n713 = ~n743;
    assign n744 = ~n745;
    assign n746 = (~n702 & ~n1000);
    assign n747 = (~n748 & ~n749);
    assign n750 = ~n751;
    assign n752 = ~n753;
    assign n754 = ~n755;
    assign n756 = ~n757;
    assign n758 = ~n759;
    assign n760 = (~n743 & ~n761 & ~n709);
    assign n762 = ~n763;
    assign n764 = (~n765 & ~n749);
    assign n766 = (~n767 & ~n749);
    assign n768 = (~\State[1]  & ~n769 & ~n770);
    assign n771 = (~\State[0]  & ~\mode[1]  & ~n772);
    assign n773 = (~\State[1]  & ~n774);
    assign n775 = (~\State[0]  & ~n776);
    assign n777 = (~\counter12[10]  & ~n750 & ~n778);
    assign n731 = ~write;
    assign n732 = ~selectCR;
    assign n779 = ~\counter12[2] ;
    assign n780 = ~\counter12[9] ;
    assign n781 = ~\counter12[8] ;
    assign n782 = ~\counter12[3] ;
    assign n783 = ~\counter12[7] ;
    assign n784 = ~\counter12[4] ;
    assign n785 = ~\counter12[6] ;
    assign n786 = ~\counter12[5] ;
    assign n787 = ~\counter12[0] ;
    assign n788 = ~\counter12[1] ;
    assign n789 = ~\counter12[10] ;
    assign n733 = (~pdModeOut & ~pwModeOut);
    assign n767 = ~loadLow;
    assign n765 = ~loadHigh;
    assign n748 = ~load4PDM;
    assign n703 = (~loadLow & ~loadHigh & ~load4PDM);
    assign n749 = ~n742;
    assign n737 = (~\counter12[1]  & ~\counter12[2]  & ~\counter12[0] );
    assign n735 = (~n736 & ~\counter12[4]  & ~\counter12[3] );
    assign n741 = (~n734 & ~\counter12[5]  & ~\counter12[6] );
    assign n739 = (~n740 & ~\counter12[7]  & ~\counter12[8] );
    assign n751 = (~n738 & ~\counter12[9] );
    assign n790 = (~n750 & ~\counter12[10] );
    assign n778 = ~n746;
    assign n791 = (~n790 & ~n778);
    assign n792 = (~n791 & ~n1000);
    assign n793 = ~n766;
    assign n794 = ~\timerLowData[11] ;
    assign n795 = ~n764;
    assign n796 = ~\timerHighData[11] ;
    assign n797 = (~n793 & ~n794);
    assign n798 = (~n795 & ~n796);
    assign n729 = (~n747 & ~n797 & ~n798 & ~n799 & ~n800);
    assign n801 = (~n702 & ~n751);
    assign n802 = (~n801 & ~n1000);
    assign n803 = ~\timerLowData[10] ;
    assign n804 = ~\timerHighData[10] ;
    assign n805 = (~n789 & ~n802);
    assign n806 = (~n793 & ~n803);
    assign n807 = (~n795 & ~n804);
    assign n728 = (~n805 & ~n806 & ~n807 & ~n777 & ~n747);
    assign n808 = (~n702 & ~n739);
    assign n809 = (~n808 & ~n1000);
    assign n810 = ~\timerLowData[9] ;
    assign n811 = ~\timerHighData[9] ;
    assign n812 = (~n780 & ~n809);
    assign n813 = (~n793 & ~n810);
    assign n814 = (~n795 & ~n811);
    assign n815 = (~n750 & ~n778);
    assign n727 = (~n812 & ~n813 & ~n814 & ~n815 & ~n747);
    assign n816 = (~n702 & ~n741);
    assign n759 = (~n816 & ~n1000);
    assign n817 = (~n702 & ~n783);
    assign n818 = (~n817 & ~n758);
    assign n819 = ~\timerLowData[8] ;
    assign n820 = ~\timerHighData[8] ;
    assign n821 = (~n781 & ~n818);
    assign n822 = (~n793 & ~n819);
    assign n823 = (~n795 & ~n820);
    assign n824 = (~n738 & ~n778);
    assign n726 = (~n821 & ~n822 & ~n823 & ~n824 & ~n747);
    assign n825 = ~\timerLowData[7] ;
    assign n826 = ~\timerHighData[7] ;
    assign n827 = (~n793 & ~n825);
    assign n828 = (~n795 & ~n826);
    assign n725 = (~n747 & ~n827 & ~n828 & ~n829 & ~n830);
    assign n831 = (~n702 & ~n735);
    assign n757 = (~n831 & ~n1000);
    assign n832 = (~n702 & ~n786);
    assign n833 = (~n832 & ~n756);
    assign n834 = ~\timerLowData[6] ;
    assign n835 = ~\timerHighData[6] ;
    assign n836 = (~n785 & ~n833);
    assign n837 = (~n793 & ~n834);
    assign n838 = (~n795 & ~n835);
    assign n839 = (~n740 & ~n778);
    assign n724 = (~n836 & ~n837 & ~n838 & ~n839 & ~n747);
    assign n840 = ~\timerLowData[5] ;
    assign n841 = ~\timerHighData[5] ;
    assign n842 = (~n793 & ~n840);
    assign n843 = (~n795 & ~n841);
    assign n723 = (~n747 & ~n842 & ~n843 & ~n844 & ~n845);
    assign n846 = (~n702 & ~n737);
    assign n755 = (~n846 & ~n1000);
    assign n847 = (~n702 & ~n782);
    assign n848 = (~n847 & ~n754);
    assign n849 = ~\timerLowData[4] ;
    assign n850 = ~\timerHighData[4] ;
    assign n851 = (~n784 & ~n848);
    assign n852 = (~n793 & ~n849);
    assign n853 = (~n795 & ~n850);
    assign n854 = (~n734 & ~n778);
    assign n722 = (~n851 & ~n852 & ~n853 & ~n854 & ~n747);
    assign n855 = ~\timerLowData[3] ;
    assign n856 = ~\timerHighData[3] ;
    assign n857 = (~n793 & ~n855);
    assign n858 = (~n795 & ~n856);
    assign n721 = (~n747 & ~n857 & ~n858 & ~n859 & ~n860);
    assign n861 = (~n702 & ~n787);
    assign n753 = (~n861 & ~n1000);
    assign n862 = (~n702 & ~n788);
    assign n863 = (~n862 & ~n752);
    assign n864 = ~\timerLowData[2] ;
    assign n865 = ~\timerHighData[2] ;
    assign n866 = (~n779 & ~n863);
    assign n867 = (~n793 & ~n864);
    assign n868 = (~n795 & ~n865);
    assign n869 = (~n736 & ~n778);
    assign n720 = (~n866 & ~n867 & ~n868 & ~n869 & ~n747);
    assign n870 = ~\timerLowData[1] ;
    assign n871 = ~\timerHighData[1] ;
    assign n872 = (~n793 & ~n870);
    assign n873 = (~n795 & ~n871);
    assign n719 = (~n747 & ~n872 & ~n873 & ~n874 & ~n875);
    assign n876 = ~\timerLowData[0] ;
    assign n877 = ~\timerHighData[0] ;
    assign n878 = (~n793 & ~n876);
    assign n879 = (~n795 & ~n877);
    assign n718 = (~n747 & ~n878 & ~n879 & ~n880 & ~n881);
    assign n743 = (~\counter12[11]  & ~\counter12[5]  & ~\counter12[6]  & ~
        \counter12[10]  & ~\counter12[1]  & ~\counter12[4]  & ~\counter12[7] 
         & ~\counter12[3]  & ~\counter12[8]  & ~\counter12[9]  & ~
        \counter12[2]  & ~n787);
    assign n772 = ~\mode[0] ;
    assign n776 = ~\mode[1] ;
    assign n769 = ~\State[0] ;
    assign n704 = ~\State[2] ;
    assign n761 = ~\State[1] ;
    assign n882 = (~n761 & ~\State[2] );
    assign n709 = ~n775;
    assign n883 = (~extSync & ~n776);
    assign n884 = (~n883 & ~n885);
    assign n886 = (~\State[1]  & ~n884);
    assign n887 = (~n886 & ~n760);
    assign n711 = ~n771;
    assign n888 = (~n704 & ~n887);
    assign n717 = (~n888 & ~n889 & ~n890);
    assign n770 = (~\mode[0]  & ~\mode[1] );
    assign n891 = (~n769 & ~n704);
    assign n763 = (~n743 & ~\State[2] );
    assign n774 = ~extSync;
    assign n892 = (~n773 & ~n704);
    assign n714 = ~n768;
    assign n893 = (~n743 & ~n761 & ~n770 & ~n891);
    assign n894 = (~n772 & ~n709 & ~n892);
    assign n895 = (~n763 & ~n714);
    assign n716 = (~n893 & ~n894 & ~n895);
    assign n896 = (~\State[2]  & ~\State[1] );
    assign n745 = (~n896 & ~n773);
    assign n897 = (~\State[2]  & ~n713);
    assign n710 = (~n897 & ~n744);
    assign n898 = (~n762 & ~n769 & ~n770);
    assign n707 = (~n898 & ~n1001);
    assign n899 = (~\mode[1]  & ~n713 & ~n761);
    assign n900 = (~n899 & ~n744);
    assign n901 = (~\State[0]  & ~n772 & ~n900);
    assign n715 = (~n901 & ~n1003);
    assign n902 = (~n713 & ~n761);
    assign n712 = (~n902 & ~n744);
    assign n903 = (~n773 & ~n763 & ~n904 & ~n905);
    assign n906 = (~n761 & ~n711);
    assign n907 = (~n770 & ~n903);
    assign n708 = (~n906 & ~n907 & ~n760);
    assign n908 = (~\State[0]  & ~n761);
    assign n705 = (~n908 & ~n768);
    assign n706 = ~pdmLess;
    assign n730 = (~reset & ~loadHigh);
    assign \randomData[9]  = ~n909;
    assign \randomData[8]  = ~n910;
    assign \randomData[7]  = ~n911;
    assign \randomData[6]  = ~n912;
    assign \randomData[11]  = ~n913;
    assign \randomData[10]  = ~n914;
    assign n915 = ~n916;
    assign preScaleClk = ~n618;
    assign n885 = ~n917;
    assign n918 = ~syncIn[0];
    assign n919 = ~\syncSource[0] ;
    assign n920 = ~syncIn[1];
    assign n921 = (~\syncSource[0]  & ~n918);
    assign n922 = (~n919 & ~n920);
    assign n923 = (~n921 & ~n922);
    assign n924 = ~syncIn[2];
    assign n925 = ~syncIn[3];
    assign n926 = (~\syncSource[0]  & ~n924);
    assign n927 = (~n919 & ~n925);
    assign n928 = (~n926 & ~n927);
    assign n929 = ~\syncSource[1] ;
    assign n930 = (~\syncSource[1]  & ~n923);
    assign n931 = (~n928 & ~n929);
    assign n932 = (~n930 & ~n931);
    assign n933 = ~syncIn[4];
    assign n934 = ~syncIn[5];
    assign n935 = (~\syncSource[0]  & ~n933);
    assign n936 = (~n919 & ~n934);
    assign n937 = (~n935 & ~n936);
    assign n938 = ~syncIn[6];
    assign n939 = ~syncIn[7];
    assign n940 = (~\syncSource[0]  & ~n938);
    assign n941 = (~n919 & ~n939);
    assign n942 = (~n940 & ~n941);
    assign n943 = (~\syncSource[1]  & ~n937);
    assign n944 = (~n929 & ~n942);
    assign n945 = (~n943 & ~n944);
    assign n946 = ~\syncSource[2] ;
    assign n947 = (~\syncSource[2]  & ~n932);
    assign n948 = (~n945 & ~n946);
    assign n916 = (~n947 & ~n948);
    assign n949 = ~syncPolarity;
    assign n950 = (~n915 & ~n949);
    assign n951 = (~syncPolarity & ~n916);
    assign syncPulse = (~n950 & ~n951);
    assign n952 = (~\counter12[9]  & ~n779);
    assign n953 = (~\counter12[2]  & ~n780);
    assign n909 = (~n952 & ~n953);
    assign n954 = (~\counter12[3]  & ~n781);
    assign n955 = (~\counter12[8]  & ~n782);
    assign n910 = (~n954 & ~n955);
    assign n956 = (~\counter12[4]  & ~n783);
    assign n957 = (~\counter12[7]  & ~n784);
    assign n911 = (~n956 & ~n957);
    assign n958 = (~\counter12[5]  & ~n785);
    assign n959 = (~\counter12[6]  & ~n786);
    assign n912 = (~n958 & ~n959);
    assign n960 = ~\counter12[11] ;
    assign n961 = (~\counter12[11]  & ~n787);
    assign n962 = (~\counter12[0]  & ~n960);
    assign n913 = (~n961 & ~n962);
    assign n963 = (~\counter12[10]  & ~n788);
    assign n964 = (~\counter12[1]  & ~n789);
    assign n914 = (~n963 & ~n964);
    assign n965 = ~\clkCount[0] ;
    assign n966 = ~\clkPreScale[0] ;
    assign n967 = ~\clkCount[1] ;
    assign n968 = (~\clkPreScale[0]  & ~n965);
    assign n969 = (~n966 & ~n967);
    assign n970 = (~n968 & ~n969);
    assign n971 = ~\clkCount[3] ;
    assign n972 = ~\clkCount[5] ;
    assign n973 = (~\clkPreScale[0]  & ~n971);
    assign n974 = (~n966 & ~n972);
    assign n975 = (~n973 & ~n974);
    assign n976 = ~\clkPreScale[1] ;
    assign n977 = (~\clkPreScale[1]  & ~n970);
    assign n978 = (~n975 & ~n976);
    assign n618 = (~n977 & ~n978);
    assign n979 = ~n777;
    assign n799 = (~\counter12[11]  & ~n979);
    assign n800 = (~n792 & ~n960);
    assign n829 = (~\counter12[7]  & ~n740 & ~n778);
    assign n830 = (~n783 & ~n759);
    assign n844 = (~\counter12[5]  & ~n734 & ~n778);
    assign n845 = (~n786 & ~n757);
    assign n859 = (~\counter12[3]  & ~n736 & ~n778);
    assign n860 = (~n782 & ~n755);
    assign n874 = (~\counter12[0]  & ~\counter12[1]  & ~n778);
    assign n875 = (~n788 & ~n753);
    assign n880 = (~\counter12[0]  & ~n778);
    assign n881 = (~shift & ~n787);
    assign n980 = (~\mode[1]  & ~n772);
    assign n981 = (~n776 & ~n769);
    assign n917 = (~n980 & ~n981);
    assign n982 = ~n882;
    assign n889 = (~n882 & ~n711);
    assign n890 = (~n713 & ~n917 & ~n982);
    assign n904 = (~\State[2]  & ~\State[0] );
    assign n905 = (~\State[1]  & ~n769);
    \**FFGEN**  pdModeOut_reg ( .next_state(n1004), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(pdModeOut) );
    \**FFGEN**  pwModeOut_reg ( .next_state(n1003), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(pwModeOut) );
    \**FFGEN**  shift_reg ( .next_state(n1002), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(shift) );
    \**FFGEN**  loadHigh_reg ( .next_state(n1001), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(loadHigh) );
    \**FFGEN**  syncPolarity_reg ( .next_state(shadowSyncPolarity), 
        .clocked_on(loadHigh), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(syncPolarity) );
    \**FFGEN**  extSync_reg ( .next_state(n1000), .clocked_on(syncPulse), 
        .force_00(n1005), .force_01(extSyncRst), .force_10(n1005), .force_11(
        n1005), .Q(extSync) );
    \**FFGEN**  load4PDM_reg ( .next_state(n999), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(load4PDM) );
    \**FFGEN**  loadLow_reg ( .next_state(n998), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(loadLow) );
    \**FFGEN**  shadowSyncPolarity_reg ( .next_state(dataIn[4]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(shadowSyncPolarity) );
    \**FFGEN**  \State_reg[0]  ( .next_state(n997), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\State[0] ) );
    \**FFGEN**  \State_reg[1]  ( .next_state(n996), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\State[1] ) );
    \**FFGEN**  \State_reg[2]  ( .next_state(n995), .clocked_on(preScaleClk), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\State[2] ) );
    \**FFGEN**  \counter12_reg[0]  ( .next_state(n994), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[0] ) );
    \**FFGEN**  \counter12_reg[1]  ( .next_state(n993), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[1] ) );
    \**FFGEN**  \counter12_reg[2]  ( .next_state(n992), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[2] ) );
    \**FFGEN**  \counter12_reg[3]  ( .next_state(n991), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[3] ) );
    \**FFGEN**  \counter12_reg[4]  ( .next_state(n990), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[4] ) );
    \**FFGEN**  \counter12_reg[5]  ( .next_state(n989), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[5] ) );
    \**FFGEN**  \counter12_reg[6]  ( .next_state(n988), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[6] ) );
    \**FFGEN**  \counter12_reg[7]  ( .next_state(n987), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[7] ) );
    \**FFGEN**  \counter12_reg[8]  ( .next_state(n986), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[8] ) );
    \**FFGEN**  \counter12_reg[9]  ( .next_state(n985), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[9] ) );
    \**FFGEN**  \counter12_reg[10]  ( .next_state(n984), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[10] ) );
    \**FFGEN**  \counter12_reg[11]  ( .next_state(n983), .clocked_on(n618), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\counter12[11] ) );
    \**FFGEN**  \syncSource_reg[0]  ( .next_state(\shadowSyncSource[0] ), 
        .clocked_on(loadHigh), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\syncSource[0] ) );
    \**FFGEN**  \syncSource_reg[1]  ( .next_state(\shadowSyncSource[1] ), 
        .clocked_on(loadHigh), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\syncSource[1] ) );
    \**FFGEN**  \syncSource_reg[2]  ( .next_state(\shadowSyncSource[2] ), 
        .clocked_on(loadHigh), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\syncSource[2] ) );
    \**FFGEN**  \clkCount_reg[0]  ( .next_state(\clkCount200[0] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[0] ) );
    \**FFGEN**  \clkCount_reg[1]  ( .next_state(\clkCount200[1] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[1] ) );
    \**FFGEN**  \clkCount_reg[2]  ( .next_state(\clkCount200[2] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[2] ) );
    \**FFGEN**  \clkCount_reg[3]  ( .next_state(\clkCount200[3] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[3] ) );
    \**FFGEN**  \clkCount_reg[4]  ( .next_state(\clkCount200[4] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[4] ) );
    \**FFGEN**  \clkCount_reg[5]  ( .next_state(\clkCount200[5] ), 
        .clocked_on(pwmClk), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\clkCount[5] ) );
    \**FFGEN**  \clkPreScale_reg[0]  ( .next_state(\shadowclkPreScale[0] ), 
        .clocked_on(n619), .force_00(n1005), .force_01(reset), .force_10(n1005
        ), .force_11(n1005), .Q(\clkPreScale[0] ) );
    \**FFGEN**  \clkPreScale_reg[1]  ( .next_state(\shadowclkPreScale[1] ), 
        .clocked_on(n619), .force_00(n1005), .force_01(reset), .force_10(n1005
        ), .force_11(n1005), .Q(\clkPreScale[1] ) );
    \**FFGEN**  \mode_reg[0]  ( .next_state(dataIn[0]), .clocked_on(writeCR), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\mode[0] ) );
    \**FFGEN**  \mode_reg[1]  ( .next_state(dataIn[1]), .clocked_on(writeCR), 
        .force_00(n1005), .force_01(reset), .force_10(n1005), .force_11(n1005), 
        .Q(\mode[1] ) );
    \**FFGEN**  \shadowclkPreScale_reg[0]  ( .next_state(dataIn[2]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\shadowclkPreScale[0] ) );
    \**FFGEN**  \shadowclkPreScale_reg[1]  ( .next_state(dataIn[3]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\shadowclkPreScale[1] ) );
    \**FFGEN**  \shadowSyncSource_reg[0]  ( .next_state(dataIn[5]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\shadowSyncSource[0] ) );
    \**FFGEN**  \shadowSyncSource_reg[1]  ( .next_state(dataIn[6]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\shadowSyncSource[1] ) );
    \**FFGEN**  \shadowSyncSource_reg[2]  ( .next_state(dataIn[7]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\shadowSyncSource[2] ) );
    \**FFGEN**  \timerLowData_reg[0]  ( .next_state(dataIn[8]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[0] ) );
    \**FFGEN**  \timerLowData_reg[1]  ( .next_state(dataIn[9]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[1] ) );
    \**FFGEN**  \timerLowData_reg[2]  ( .next_state(dataIn[10]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[2] ) );
    \**FFGEN**  \timerLowData_reg[3]  ( .next_state(dataIn[11]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[3] ) );
    \**FFGEN**  \timerLowData_reg[4]  ( .next_state(dataIn[12]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[4] ) );
    \**FFGEN**  \timerLowData_reg[5]  ( .next_state(dataIn[13]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[5] ) );
    \**FFGEN**  \timerLowData_reg[6]  ( .next_state(dataIn[14]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[6] ) );
    \**FFGEN**  \timerLowData_reg[7]  ( .next_state(dataIn[15]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[7] ) );
    \**FFGEN**  \timerLowData_reg[8]  ( .next_state(dataIn[16]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[8] ) );
    \**FFGEN**  \timerLowData_reg[9]  ( .next_state(dataIn[17]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[9] ) );
    \**FFGEN**  \timerLowData_reg[10]  ( .next_state(dataIn[18]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[10] ) );
    \**FFGEN**  \timerLowData_reg[11]  ( .next_state(dataIn[19]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerLowData[11] ) );
    \**FFGEN**  \timerHighData_reg[0]  ( .next_state(dataIn[20]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[0] ) );
    \**FFGEN**  \timerHighData_reg[1]  ( .next_state(dataIn[21]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[1] ) );
    \**FFGEN**  \timerHighData_reg[2]  ( .next_state(dataIn[22]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[2] ) );
    \**FFGEN**  \timerHighData_reg[3]  ( .next_state(dataIn[23]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[3] ) );
    \**FFGEN**  \timerHighData_reg[4]  ( .next_state(dataIn[24]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[4] ) );
    \**FFGEN**  \timerHighData_reg[5]  ( .next_state(dataIn[25]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[5] ) );
    \**FFGEN**  \timerHighData_reg[6]  ( .next_state(dataIn[26]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[6] ) );
    \**FFGEN**  \timerHighData_reg[7]  ( .next_state(dataIn[27]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[7] ) );
    \**FFGEN**  \timerHighData_reg[8]  ( .next_state(dataIn[28]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[8] ) );
    \**FFGEN**  \timerHighData_reg[9]  ( .next_state(dataIn[29]), .clocked_on(
        writeCR), .force_00(n1005), .force_01(reset), .force_10(n1005), 
        .force_11(n1005), .Q(\timerHighData[9] ) );
    \**FFGEN**  \timerHighData_reg[10]  ( .next_state(dataIn[30]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\timerHighData[10] ) );
    \**FFGEN**  \timerHighData_reg[11]  ( .next_state(dataIn[31]), 
        .clocked_on(writeCR), .force_00(n1005), .force_01(reset), .force_10(
        n1005), .force_11(n1005), .Q(\timerHighData[11] ) );
    pwm12_8s_DW01_incdec_6_0 add_99 ( .A({\clkCount[5] , \clkCount[4] , 
        \clkCount[3] , \clkCount[2] , \clkCount[1] , \clkCount[0] }), 
        .INC_DEC(n1005), .SUM({\clkCount200[5] , \clkCount200[4] , 
        \clkCount200[3] , \clkCount200[2] , \clkCount200[1] , \clkCount200[0] 
        }) );
    pwm12_8s_DW01_cmp2_12_0 lte_190 ( .A({\timerHighData[11] , 
        \timerHighData[10] , \timerHighData[9] , \timerHighData[8] , 
        \timerHighData[7] , \timerHighData[6] , \timerHighData[5] , 
        \timerHighData[4] , \timerHighData[3] , \timerHighData[2] , 
        \timerHighData[1] , \timerHighData[0] }), .B({\randomData[11] , 
        \randomData[10] , \randomData[9] , \randomData[8] , \randomData[7] , 
        \randomData[6] , \counter12[5] , \counter12[4] , \counter12[3] , 
        \counter12[2] , \counter12[1] , \counter12[0] }), .LEQ(n1005), .TC(
        n1005), .GE_GT(pdmLess) );
endmodule

