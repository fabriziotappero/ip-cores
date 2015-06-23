; Simulator generator support routines.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.

; Utilities of cgen-arch.h.

; Return C macro definitions of the various supported cpus.

(define (-gen-cpuall-defines)
  "" ; nothing yet
)

; Return C declarations of misc. support stuff.
; ??? Modes are now defined in sim/common/cgen-types.h but we will need
; target specific modes.

(define (-gen-support-decls)
  (string-append
;   (gen-enum-decl 'mode_type "mode types"
;		  "MODE_"
;		  ; Aliases are not distinct from their real mode so ignore
;		  ; them here.
;		  (append (map list (map obj:name
;					 (mode-list-non-alias-values)))
;			  '((max))))
;   "#define MAX_MODES ((int) MODE_MAX)\n\n"
   )
)

; Utilities of cgen-cpuall.h.

; Subroutine of -gen-cpuall-includes.

(define (-gen-cpu-header cpu prefix)
  (string-append "#include \"" prefix (cpu-file-transform cpu) ".h\"\n")
)

; Return C code to include all the relevant headers for each cpu family,
; conditioned on ifdef WANT_CPU_@CPU@.

(define (-gen-cpuall-includes)
  (string-list
   "/* Include files for each cpu family.  */\n\n"
   (string-list-map (lambda (cpu)
		      (let* ((cpu-name (gen-sym cpu))
			     (CPU-NAME (string-upcase cpu-name)))
			(string-list "#ifdef WANT_CPU_" CPU-NAME "\n"
				     (-gen-cpu-header cpu "eng")
				     "#include \"cgen-engine.h\"\n"
				     (-gen-cpu-header cpu "cpu")
				     ; FIXME: Shorten "decode" to "dec".
				     (-gen-cpu-header cpu "decode")
				     "#endif\n\n")))
		    (current-cpu-list))
   )
)

; Subroutine of -gen-cpuall-decls to generate cpu-specific structure entries.
; The result is "struct <cpu>_<type-name> <member-name>;".
; INDENT is the amount to indent by.
; CPU is the cpu object.

(define (-gen-cpu-specific-decl indent cpu type-name member-name)
  (let* ((cpu-name (gen-sym cpu))
	 (CPU-NAME (string-upcase cpu-name)))
    (string-append
     "#ifdef WANT_CPU_" CPU-NAME "\n"
     (spaces indent)
     "struct " cpu-name "_" type-name " " member-name ";\n"
     "#endif\n"))
)

; Return C declarations of cpu-specific structs.
; These are defined here to achieve a simple and moderately type-safe
; inheritance.  In the non-cpu-specific files, these structs consist of
; just the baseclass.  In cpu-specific files, the baseclass is augmented
; with the cpu-specific data.

(define (-gen-cpuall-decls)
  (string-list
   (gen-argbuf-type #f)
   (gen-scache-type #f)
   )
)

; Top level generators for non-cpu-specific files.

; Generate arch.h
; This file defines non cpu family specific data about the architecture
; and also data structures that combine all variants (e.g. cpu struct).
; It is intended to be included before sim-basics.h and sim-base.h.

(define (cgen-arch.h)
  (logit 1 "Generating " (current-arch-name) "'s arch.h ...\n")

  (string-write
   (gen-c-copyright "Simulator header for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "#ifndef @ARCH@_ARCH_H\n"
   "#define @ARCH@_ARCH_H\n"
   "\n"
   "#define TARGET_BIG_ENDIAN 1\n\n" ; FIXME
   ;(gen-mem-macros)
   ;"/* FIXME: split into 32/64 parts */\n"
   ;"#define WI SI\n"
   ;"#define UWI USI\n"
   ;"#define AI USI\n\n"
   -gen-cpuall-defines
   -gen-support-decls
   -gen-arch-model-decls
   "#endif /* @ARCH@_ARCH_H */\n"
   )
)

; Generate arch.c
; This file defines non cpu family specific data about the architecture.

(define (cgen-arch.c)
  (logit 1 "Generating " (current-arch-name) "'s arch.c ...\n")

  (string-write
   (gen-c-copyright "Simulator support for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#include \"sim-main.h\"
#include \"bfd.h\"

"
   -gen-mach-data
   )
)

; Generate cpuall.h
; This file pulls together all of the cpu variants .h's.
; It is intended to be included after sim-base.h/cgen-sim.h.

(define (cgen-cpuall.h)
  (logit 1 "Generating " (current-arch-name) "'s cpuall.h ...\n")

  (string-write
   (gen-c-copyright "Simulator CPU header for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "#ifndef @ARCH@_CPUALL_H\n"
   "#define @ARCH@_CPUALL_H\n"
   "\n"
   -gen-cpuall-includes
   -gen-mach-decls
   -gen-cpuall-decls
   "#endif /* @ARCH@_CPUALL_H */\n"
   )
)

; Generate ops.c
; No longer used.

(define (cgen-ops.c)
  (logit 1 "Generating " (current-arch-name) "'s ops.c ...\n")

  (string-write
   (gen-c-copyright "Simulator operational support for @arch@."
		  CURRENT-COPYRIGHT CURRENT-PACKAGE)
   "\
#define MEMOPS_DEFINE_INLINE

#include \"config.h\"
#include <signal.h>
#include \"ansidecl.h\"
#include \"bfd.h\"
#include \"tconfig.h\"
#include \"cgen-sim.h\"
#include \"memops.h\"

/* FIXME: wip */
int pow2masks[] = {
  0, 0, 1, -1, 3, -1, -1, -1, 7, -1, -1, -1, -1, -1, -1, -1, 15
};

"
   gen-mode-defs
   )
)
