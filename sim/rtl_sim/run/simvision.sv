# SimVision Command Script (Sat Feb 28 15:57:27 CET 2004)

#
# Databases
#
if {[database find -match exact -name "waves"] == {}} {
    database open /projects/simple_spi/sim/rtl_sim/run/waves/waves.trn -name "waves"
}

#
# Cursors
#
set time 86000ps
if {[cursor find -match exact -name "TimeC"] == {}} {
    cursor new -name  "TimeC" -time $time
} else {
    cursor set -using "TimeC" -time $time
}
set time 0
if {[cursor find -match exact -name "TimeH"] == {}} {
    cursor new -name  "TimeH" -time $time
} else {
    cursor set -using "TimeH" -time $time
}
set time 0
if {[cursor find -match exact -name "TimeB"] == {}} {
    cursor new -name  "TimeB" -time $time
} else {
    cursor set -using "TimeB" -time $time
}
set time 0
if {[cursor find -match exact -name "TimeD"] == {}} {
    cursor new -name  "TimeD" -time $time
} else {
    cursor set -using "TimeD" -time $time
}
set time 14.16ns
if {[cursor find -match exact -name "TimeA"] == {}} {
    cursor new -name  "TimeA" -time $time
} else {
    cursor set -using "TimeA" -time $time
}
set time 0
if {[cursor find -match exact -name "TimeE"] == {}} {
    cursor new -name  "TimeE" -time $time
} else {
    cursor set -using "TimeE" -time $time
}

#
# Groups
#

if {[group find -match exact -name "Wishbone"] == {}} {
    group new -name "Wishbone" -overlay 0
} else {
    group using "Wishbone"
    group set -overlay 0
    group clear 0 end
}
group insert \
    {waves::tst_bench_top.spi_top.clk_i} \
    {waves::tst_bench_top.spi_top.rst_i} \
    {waves::tst_bench_top.spi_top.cyc_i} \
    {waves::tst_bench_top.spi_top.stb_i} \
    {waves::tst_bench_top.spi_top.adr_i[1:0]} \
    {waves::tst_bench_top.spi_top.we_i} \
    {waves::tst_bench_top.spi_top.dat_i[7:0]} \
    {waves::tst_bench_top.spi_top.dat_o[7:0]} \
    {waves::tst_bench_top.spi_top.ack_o} \
    {waves::tst_bench_top.spi_top.inta_o}

if {[group find -match exact -name "spi"] == {}} {
    group new -name "spi" -overlay 0
} else {
    group using "spi"
    group set -overlay 0
    group clear 0 end
}
group insert \
    {waves::tst_bench_top.spi_slave.csn} \
    {waves::tst_bench_top.spi_slave.sck} \
    {waves::tst_bench_top.spi_slave.di} \
    {waves::tst_bench_top.spi_slave.do}

#
# Design Browser Windows
#
if {[window find -match exact -name "Design Browser 1"] == {}} {
    window new DesignBrowser -name "Design Browser 1" -geometry 700x500+6+20
} else {
    window geometry "Design Browser 1" 700x500+6+20
}
window target "Design Browser 1" on
browser using "Design Browser 1"
browser set \
    -scope {waves::tst_bench_top.spi_slave}

#
# Waveform Windows
#
if {[window find -match exact -name "Waveform 5"] == {}} {
    window new WaveWindow -name "Waveform 5" -geometry 1010x600+148+327
} else {
    window geometry "Waveform 5" 1010x600+148+327
}
window target "Waveform 5" on
waveform using "Waveform 5"
waveform set \
    -primarycursor "TimeE" \
    -signalnames name \
    -signalwidth 175 \
    -units ns \
    -valuewidth 75
cursor set -using "TimeE" -time 0
waveform baseline set -time 0

set groupId [waveform add -groups {"Wishbone"}]
set startIndex [lsearch -exact [waveform find] $groupId]
set id [lindex [waveform find] [expr {$startIndex + 1}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 2}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 3}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 4}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 5}]]
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 6}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 7}]]
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 8}]]
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 9}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 10}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
waveform hierarchy collapse $groupId

set groupId [waveform add -groups {"spi"}]
set startIndex [lsearch -exact [waveform find] $groupId]
set id [lindex [waveform find] [expr {$startIndex + 1}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 2}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 3}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
set id [lindex [waveform find] [expr {$startIndex + 4}]]
waveform format $id -radix %b
waveform format $id -trace "digital" -color "" -symbol ""
waveform hierarchy collapse $groupId


waveform xview limits 0 2000ns

#
# Preferences
#
preferences set ams-show-flow {1}
preferences set ams-show-potential {1}
preferences set analog-height {5}
preferences set color-verilog-by-value {1}
preferences set create-cursor-for-new-window {0}
preferences set cv-num-lines {25}
preferences set cv-show-only {1}
preferences set db-scope-gen-compnames {0}
preferences set db-scope-gen-icons {1}
preferences set db-scope-gen-sort {name}
preferences set db-scope-gen-tracksb {0}
preferences set db-scope-systemc-processes {1}
preferences set db-scope-verilog-cells {1}
preferences set db-scope-verilog-functions {1}
preferences set db-scope-verilog-namedbegins {1}
preferences set db-scope-verilog-namedforks {1}
preferences set db-scope-verilog-tasks {1}
preferences set db-scope-vhdl-assertions {1}
preferences set db-scope-vhdl-assignments {1}
preferences set db-scope-vhdl-blocks {1}
preferences set db-scope-vhdl-breakstatements {1}
preferences set db-scope-vhdl-calls {1}
preferences set db-scope-vhdl-generates {1}
preferences set db-scope-vhdl-processstatements {1}
preferences set db-show-editbuf {0}
preferences set db-show-modnames {0}
preferences set db-show-values {simulator}
preferences set db-signal-filter-constants {1}
preferences set db-signal-filter-generics {1}
preferences set db-signal-filter-other {1}
preferences set db-signal-filter-quantities {1}
preferences set db-signal-filter-signals {1}
preferences set db-signal-filter-terminals {1}
preferences set db-signal-filter-variables {1}
preferences set db-signal-gen-radix {default}
preferences set db-signal-gen-showdetail {0}
preferences set db-signal-gen-showstrength {0}
preferences set db-signal-gen-sort {name}
preferences set db-signal-show-assertions {1}
preferences set db-signal-show-errorsignals {1}
preferences set db-signal-show-fibers {1}
preferences set db-signal-show-inouts {1}
preferences set db-signal-show-inputs {1}
preferences set db-signal-show-internal {1}
preferences set db-signal-show-mutexes {1}
preferences set db-signal-show-outputs {1}
preferences set db-signal-show-semaphores {1}
preferences set db-signal-vlogfilter-branches {1}
preferences set db-signal-vlogfilter-memories {1}
preferences set db-signal-vlogfilter-parameters {1}
preferences set db-signal-vlogfilter-registers {1}
preferences set db-signal-vlogfilter-variables {1}
preferences set db-signal-vlogfilter-wires {1}
preferences set default-ams-formatting {potential}
preferences set default-time-units {ns}
preferences set delete-unused-cursors-on-exit {1}
preferences set delete-unused-groups-on-exit {1}
preferences set enable-toolnet {0}
preferences set initial-zoom-out-full {0}
preferences set key-bindings {
	Edit>Undo "Ctrl+Z"
	Edit>Redo "Ctrl+Y"
	Edit>Copy "Ctrl+C"
	Edit>Cut "Ctrl+X"
	Edit>Paste "Ctrl+V"
	Edit>Delete "Del"
	openDB "Ctrl+O"
	View>Zoom>InX "Alt+I"
	View>Zoom>OutX "Alt+O"
	View>Zoom>FullX "Alt+="
	View>Zoom>InX_widget "I"
	View>Zoom>OutX_widget "O"
	View>Zoom>FullX_widget "="
	View>Zoom>Cursor-Baseline "Alt+Z"
	View>Center "Alt+C"
	View>ExpandSequenceTime>AtCursor "Alt+X"
	View>CollapseSequenceTime>AtCursor "Alt+S"
	Edit>Create>Group "Ctrl+G"
	Edit>Ungroup "Ctrl+Shift+G"
	Edit>Create>Marker "Ctrl+M"
	Edit>Create>Condition "Ctrl+E"
	Edit>Create>Bus "Ctrl+W"
	Explore>NextEdge "Ctrl+\]"
	Explore>PreviousEdge "Ctrl+\["
	ScrollRight "Right arrow"
	ScrollLeft "Left arrow"
	ScrollUp "Up arrow"
	ScrollDown "Down arrow"
	PageUp "PageUp"
	PageDown "PageDown"
	TopOfPage "Home"
	BottomOfPage "End"
}
preferences set marching-waveform {1}
preferences set prompt-exit {1}
preferences set prompt-on-reinvoke {1}
preferences set restore-state-on-startup {0}
preferences set save-state-on-startup {0}
preferences set sb-editor-command {xterm -e vi +%L %F}
preferences set sb-history-size {10}
preferences set sb-module-only {0}
preferences set sb-radix {default}
preferences set sb-show-strength {1}
preferences set sb-syntax-highlight {0}
preferences set sb-syntax-types {
    {
	-name "VHDL/VHDL-AMS" -dacname "vhdl" -extensions {.vhd .vhdl}
	-ignorecase 1 -multiline {} -singleline {--} -singlechar {} -onechar {'}
	-keywords {
	    \{ abs access after alias all 
	    and architecture array assert attribute 
	    begin block body buffer bus 
	    case component configuration constant disconnect 
	    downto else elsif end entity 
	    exit file for function generate
	    generic group guarded if impure 
	    in inertial inout is label 
	    library linkage literal loop map
	    mod nand new next nor
	    not null of on open
	    or others out package port
	    postponed procedure process pure range
	    record register reject rem report
	    return rol ror select severity
	    signal shared sla sll sra 
	    srl subtype then to transport
	    type unaffected units until use
	    variable wait when while xnor 
	    xor `base `left `right `high 
	    `low `ascending `image `value `pos 
	    `val `succ `pred `leftof `rightof
	    `range `reverse_range `length `delayed `stable 
	    `quiet `transaction `event `last_event `last_active 
	    `last_value `driving `driving_value `simple_name `instance_name 
	    `path_name
            across break nature noise quantity procedural
            reference spectrum subnature terminal through
            tolerance \}
	}
    }
    {
	-name "Verilog/Verilog-AMS" -dacname "verilog" -extensions {.v .vams .vms .va}
	-multiline {/* */} -singleline {//} -singlechar {}
	-keywords {
	    \{ always and assign attribute begin 
	    buf bufif0 bufif1 case casex
	    casez cmos deassign default defparam 
	    disable edge else end endattribute 
	    endcase endmodule endfunction endprimitive endspecify 
	    endtable endtask event for force 
	    forever fork function highz0 highz1 
	    if initial inout input integer 
	    join large macromodule medium module 
	    nand negedge nmos nor not 
	    notif0 notif1 or output parameter 
	    pmos posedge primitive pull0 pull1 
	    pullup pulldown rcmos reg release 
	    repeat rnmos rpmos rtran rtranif0 
	    rtranif1 scalared small specify specparam 
	    strength strong0 strong1 supply0 supply1 
	    table task time tran tranif0 
	    tranif1 tri tri0 tri1 triand 
	    trior trireg use vectored wait
	    wand weak0 weak1 while wire
	    wor xnor xor 
            nature endnature abstol access ddt_nature idt_nature
            units flow potential discipline enddiscipline domain
            discrete continuous branch genvar analog generate
            cross above timer initial_step final_step ddt
            idt idtmod absdelay transition slew laplace_zd
            laplace_zp laplace_nd laplace_np last_crossing zi_zp
            zi_zd zi_np zi_nd ac_stim white_noise flicker_noise
            noise_table analysis ln log exp sqrt min max abs pow
            ceil floor sin cos tan asin acos atan atan2 sinh cosh
            tanh asinh acosh atanh hypot driver_update connectrules
            endconnectrules connectmodule connect resolveto split
            merged inf from exclude ground wreal dynamicparam \}
	}
    }
    {
	-name "C" -dacname "c" -extensions {.c}
	-multiline {/* */} -singleline {}
	-keywords {
	    \{ asm auto break case catch
	    cdecl char class const continue 
	    default define delete do double 
	    else enum extern far float 
	    for goto huge if include 
	    inline int interrupt long near 
	    operator pascal register return short 
	    signed sizeof static struct switch 
	    typedef union unsigned void volatile 
	    while \}
	}
    }
    {
	-name "C++" -dacname "c++" -extensions {.h .hpp .cc .cpp .CC}
	-multiline {/* */} -singleline {//}  
	-keywords {
	    \{ asm auto break case catch 
	    cdecl char class const continue 
	    default define delete do double 
	    else enum extern far float 
	    for friend goto huge if 
	    include inline int interrupt long 
	    near new operator pascal private 
	    protected public register return short 
	    signed sizeof static struct switch 
	    template this typedef union unsigned 
	    virtual void volatile while \}
	}
    }
    {
	-name "SystemC" -dacname "systemc" -extensions {.h .hpp .cc .cpp .CC} 
	-multiline {/* */} -singleline {//} 
	-keywords {
	    \{ asm auto break case catch 
	    cdecl char class const continue 
	    default define delete do double 
	    else enum extern far float 
	    for friend goto huge if 
	    include inline int interrupt long 
	    near new operator pascal private 
	    protected public register return short 
	    signed sizeof static struct switch 
	    template this typedef union unsigned 
	    virtual void volatile while \}
	}
    }
}
preferences set sb-tab-size {8}
preferences set schematic-show-values {simulator}
preferences set search-toolbar {1}
preferences set seq-time-width {30}
preferences set sfb-colors {
	register #beded1
	variable #beded1
	assignStmt gray85
	force #faa385
}
preferences set sfb-default-tree {0}
preferences set sfb-max-cell-width {40}
preferences set show-database-names {0}
preferences set show-full-signal-names {0}
preferences set show-times-on-cursors {1}
preferences set show-times-on-markers {1}
preferences set signal-type-colors {
	group #0000FF
	overlay #0000FF
	input #FFFF00
	output #FFA500
	inout #00FFFF
	internal #00FF00
	fiber #FF99FF
	errorsignal #FF0000
	assertion #FF0000
	unknown #FFFFFF
}
preferences set snap-to-edge {1}
preferences set toolbars-style {icon}
preferences set transaction-height {3}
preferences set use-signal-type-colors {0}
preferences set use-signal-type-icons {1}
preferences set verilog-colors {
	HiZ #ff9900
	StrX #ff0000
	Sm #00ff99
	Me #0000ff
	We #00ffff
	La #ff00ff
	Pu #9900ff
	St #00ff00
	Su #ff0099
	0 #00ff00
	1 #00ff00
	X #ff0000
	Z #ff9900
	other #ffff00
}
preferences set vhdl-colors {
	U #9900ff 
	X #ff0000 
	0 #00ff00 
	1 #00ff00 
	Z #ff9900 
	W #ff0000
	L #00ffff 
	H #00ffff
	- #0000ff
}
preferences set waveform-banding {1}
preferences set waveform-height {10}
preferences set waveform-space {2}
