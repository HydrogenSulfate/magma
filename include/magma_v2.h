/*
    -- MAGMA (version 2.0) --
       Univ. of Tennessee, Knoxville
       Univ. of California, Berkeley
       Univ. of Colorado, Denver
       @date
*/

#ifndef MAGMA_V2_H
#define MAGMA_V2_H

#define MAGMA_API 2


// =============================================================================
// MAGMA configuration
#include "magma_config.h"

// =============================================================================
// MAGMA BLAS Functions

#include "magmablas.h"
#include "magma_batched.h"
#include "magma_vbatched.h"
#include "magma_bulge.h"


// =============================================================================
// MAGMA Functions

#include "magma_z.h"
#include "magma_c.h"
#include "magma_d.h"
#include "magma_s.h"
#include "magma_zc.h"
#include "magma_ds.h"
#include "magma_auxiliary.h"
#include "magma_htc.h"

#ifndef HIPBLAS_COMPUTE_32F
#define HIPBLAS_COMPUTE_32F HIPBLAS_R_32F
#endif

#ifndef HIPBLAS_COMPUTE_64F
#define HIPBLAS_COMPUTE_64F HIPBLAS_R_64F
#endif

#endif // MAGMA_V2_H
