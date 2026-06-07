import BSDBridgeC.Profile.Basic
import BSDBridgeC.Freezing.ProfileParity
import BSDBridgeC.Profile.Generality
import BSDBridgeC.Profile.LeafLocalization
import BSDBridgeC.Profile.PartialClosureAudit
import BSDBridgeC.Profile.CloseabilityAudit
import BSDBridgeC.Profile.BranchLeafRegistry

/-!
# BSD Bridge C theorem map

A `#check` index of the BSD Bridge C scaffold.
This file proves nothing.  It makes the public DAG inspectable from a
single import: every structure, definition, and theorem that the
package exposes for downstream use or paper citation appears once
below.

This file is the BSD-side counterpart of the `TheoremMap.lean` index
used in the `GaussianWhoWhere` Lean 4 / Mathlib development.
-/

namespace BSDBridgeC

/-! ## Basic objects -/
#check EllipticCurveLike
#check GaloisRep
#check TateModule
#check H1
#check SelmerQuotient
#check WedgePower
#check RankAgreement

/-! ## Who side -/
#check BSDWhoData
#check BSDWhoHeterogeneousBundle
#check bsdWhoData_to_heterogeneousBundle
#check bsdWhoData_has_torsion
#check bsdWhoData_has_sha
#check bsdWhoData_has_tamagawa
#check bsdWhoData_has_regulator
#check bsdWhoData_has_period

/-! ## Where side -/
#check BSDWhereData
#check BSDWhereCentralBundle
#check bsdWhereData_to_centralBundle
#check centralTaylor_order
#check centralTaylor_leadingCoeff
#check bsdWhereData_has_L
#check bsdWhereData_has_rootNumber
#check bsdWhereData_has_centralTaylor
#check bsdWhereData_has_functionalEquationSocket

/-! ## Compatibility socket -/
#check BSDWhoWhereCompatible
#check BSDCompatibilitySocketBundle
#check bsdWhoWhereCompatible_to_socketBundle
#check bsdWhoWhereCompatible_socketPair

/-! ## V3 Sha decomposition -/
#check MordellWeilLike
#check SelmerGroupLike
#check ShaTorsionLike
#check SelmerShaExactPackage
#check ShaDataV3
#check ShaDataWithOrderV3
#check shaData_of_v3

/-! ## V3 Sha projections -/
#check shaDataV3_carrier
#check shaDataV3_torsionAt
#check shaDataV3_selmerShaPackage
#check shaDataV3_finiteSocket

/-! ## Selmer/Sha exact-package projections -/
#check selmerShaExactPackage_mordellWeilMod
#check selmerShaExactPackage_selmer
#check selmerShaExactPackage_shaTorsion
#check selmerShaExactPackage_injectionSocket
#check selmerShaExactPackage_surjectionSocket
#check selmerShaExactPackage_exactnessSocket

/-! ## Bridge layers -/
#check ModularitySocket
#check BridgeA_Encode
#check BridgeAprime_LogDeriv
#check IwasawaMainSocket
#check BridgeB_Decode
#check BridgeC_Rigidity
#check bridgeC_has_who_where

/-! ## Bridge A internal socket projections -/
#check bridgeA_has_modularity
#check bridgeA_has_eulerProductModel
#check bridgeA_has_dirichletModel

/-! ## Bridge A′ internal socket projections -/
#check bridgeAprime_has_logDerivativeModel
#check bridgeAprime_has_poleResidueEncoding

/-! ## Bridge B internal socket projections -/
#check bridgeB_has_iwasawaMain
#check bridgeB_has_taylorToArithmetic
#check bridgeB_has_normalizationCompatibility

/-! ## Bridge C sub-bridge projections -/
#check bridgeC_has_encode
#check bridgeC_has_decode
#check bridgeC_has_logDeriv

/-! ## Higher-rank sockets -/
#check HigherEulerSystem
#check HigherKolyvaginSystem
#check HigherKolyvaginDerivative
#check HigherRankArithmeticBridge
#check HigherRankSocket
#check higherRankBridge_has_eulerSystem
#check higherRankBridge_has_kolyvaginSystem
#check higherRankBridge_has_derivative

/-! ## Higher Euler system internal projections -/
#check higherEulerSystem_classes
#check higherEulerSystem_normCompatibility

/-! ## Higher Kolyvagin system internal projections -/
#check higherKolyvaginSystem_classes
#check higherKolyvaginSystem_localRelations

/-! ## Higher Kolyvagin derivative internal projection -/
#check higherKolyvaginDerivative_law

/-! ## Higher-rank arithmetic bridge remaining sockets -/
#check higherRankBridge_has_regulatorCompatibility
#check higherRankBridge_has_selmerControl
#check higherRankBridge_has_coreRankMatchesBSDRank

/-! ## Higher-rank socket genealogy bundle -/
#check HigherRankSocketBundle
#check higherRankBridge_to_socketBundle

/-! ## V3 decomposed higher-rank sockets -/
#check RegulatorCompatibility
#check SelmerControl
#check CoreRankBSDRankCompatibility
#check HigherRankSocketStructure
#check HigherRankSocketV3
#check higherRankSocketStructure_to_arithmeticBridge
#check higherRankSocket_of_v3

/-! ## V3 socket-structure projections -/
#check higherRankSocketStructure_has_eulerSystem
#check higherRankSocketStructure_has_kolyvaginSystem
#check higherRankSocketStructure_has_derivative
#check higherRankSocketStructure_has_regulatorCompatibility
#check higherRankSocketStructure_has_selmerControl
#check higherRankSocketStructure_has_rankCompatibility

/-! ## Rank-one specialization -/
#check RankOneHeegnerWitness
#check rankOneArithmeticBridge_of_heegnerWitness
#check higherRankSocket_rankOne_of_heegnerWitness
#check rankOneProfileSocket_of_heegnerWitness

/-! ## Rank-one Heegner witness internal projections -/
#check rankOneHeegnerWitness_has_eulerSystem
#check rankOneHeegnerWitness_has_kolyvaginSystem
#check rankOneHeegnerWitness_has_derivative
#check rankOneHeegnerWitness_has_regulatorCompatibility
#check rankOneHeegnerWitness_has_selmerControl
#check rankOneHeegnerWitness_has_coreRankMatchesBSDRank

/-! ## Rank-one witness genealogy bundle -/
#check RankOneWitnessBundle
#check rankOneHeegnerWitness_to_bundle
#check rankOneHeegnerWitness_to_higherRankSocketBundle

/-! ## V3 rank-one Heegner witness -/
#check RankOneHeegnerWitnessV3
#check rankOneHeegnerWitnessV3_to_higherRankSocketStructure
#check higherRankSocketV3_rankOne_of_heegnerWitnessV3
#check rankOneHeegnerWitness_of_v3
#check rankOneHeegnerWitnessV3_to_arithmeticBridge
#check higherRankSocket_rankOne_of_heegnerWitnessV3

/-! ## V3 rank-one witness projections -/
#check rankOneHeegnerWitnessV3_has_eulerSystem
#check rankOneHeegnerWitnessV3_has_kolyvaginSystem
#check rankOneHeegnerWitnessV3_has_derivative
#check rankOneHeegnerWitnessV3_has_regulatorCompatibility
#check rankOneHeegnerWitnessV3_has_selmerControl
#check rankOneHeegnerWitnessV3_has_rankCompatibility

/-! ## V3 rank-one witness bundle -/
#check RankOneWitnessBundleV3
#check rankOneHeegnerWitnessV3_to_bundleV3

/-! ## Parity freezing -/
#check RootNumberFunctionalEquation
#check bsd_where_rootNumber_forces_centralZero
#check bsd_where_sign_neg_one_forces_vanishing

/-! ## Parity freezing wrappers (Where + Profile layers) -/
#check BSDWhereHasNegativeRootFunctionalEquation
#check bsdWhereData_centralZero_of_negativeRootFunctionalEquation
#check BSDBridgeCProfileHasNegativeRootFunctionalEquation
#check bsdBridgeCProfile_centralZero_of_negativeRootFunctionalEquation

/-! ## Leaf localization -/
#check LeafStatus
#check RefinementLeaf
#check RefinementLeaf.IsClosed
#check RefinementLeaf.IsOpen
#check LeafLocalizationProfile
#check torsion_closed_leaf
#check tamagawa_closed_leaf
#check regulator_closed_leaf
#check period_closed_leaf
#check sha_finiteness_open_leaf
#check higher_euler_system_open_leaf
#check bsd_leafLocalizationProfile
#check sha_finiteness_leaf_is_open
#check higher_euler_system_leaf_is_open
#check torsion_leaf_is_closed

/-! ## Refined Sha sub-leaves (post V3 Sha decomposition) -/
#check sha_finiteSocket_open_leaf
#check sha_selmer_injection_open_leaf
#check sha_selmer_surjection_open_leaf
#check sha_selmer_exactness_open_leaf
#check sha_finiteSocket_leaf_is_open
#check sha_selmer_injection_leaf_is_open
#check sha_selmer_surjection_leaf_is_open
#check sha_selmer_exactness_leaf_is_open
#check bsd_refinedShaLeafLocalizationProfile

/-! ## Compatibility-node open leaves -/
#check bsd_leadingCoefficientFormula_open_leaf
#check bsd_rankOrderCompatibility_open_leaf
#check bsd_leadingCoefficientFormula_leaf_is_open
#check bsd_rankOrderCompatibility_leaf_is_open
#check bsd_refinedShaAndCompatibilityLeafLocalizationProfile

/-! ## Higher-rank sub-leaves (post V3 higher-rank decomposition) -/
#check higherEuler_normCompatibility_open_leaf
#check higherKolyvagin_localRelations_open_leaf
#check higherKolyvagin_derivativeLaw_open_leaf
#check higherRank_regulatorCompatibility_open_leaf
#check higherRank_selmerControl_open_leaf
#check higherRank_analyticRankCompatibility_open_leaf
#check higherEuler_normCompatibility_leaf_is_open
#check higherKolyvagin_localRelations_leaf_is_open
#check higherKolyvagin_derivativeLaw_leaf_is_open
#check higherRank_regulatorCompatibility_leaf_is_open
#check higherRank_selmerControl_leaf_is_open
#check higherRank_analyticRankCompatibility_leaf_is_open
#check bsd_fullyRefinedLeafLocalizationProfile

/-! ## Leaf count and refinement chain -/
#check LeafStatus.isOpen
#check LeafStatus.isClosed
#check LeafLocalizationProfile.openCount
#check LeafLocalizationProfile.closedCount
#check bsd_leafLocalizationProfile_openCount
#check bsd_refinedShaLeafLocalizationProfile_openCount
#check bsd_refinedShaAndCompatibilityLeafLocalizationProfile_openCount
#check bsd_fullyRefinedLeafLocalizationProfile_openCount
#check bsd_leafLocalizationProfile_closedCount
#check bsd_refinedShaLeafLocalizationProfile_closedCount
#check bsd_refinedShaAndCompatibilityLeafLocalizationProfile_closedCount
#check bsd_fullyRefinedLeafLocalizationProfile_closedCount
#check bsd_leafLocalization_openCount_chain

/-! ## Typed leaf identifiers (V4) -/
#check BSDLeafId
#check BSDLeafId.status
#check BSDLeafId.label
#check BSDLeafId.isOpen
#check BSDLeafId.isClosed
#check bsd_closedLeafIds
#check bsd_openLeafIds
#check bsd_fullyRefinedLeafIds
#check bsd_closedLeafIds_count
#check bsd_openLeafIds_count
#check bsd_fullyRefinedLeafIds_count

/-! ## V4 typed-to-string registry bridge -/
#check BSDLeafId.toRefinementLeaf
#check BSDLeafId.toRefinementLeaf_status
#check BSDLeafId.toRefinementLeaf_label
#check BSDLeafId.toRefinementLeaf_closed_iff
#check BSDLeafId.toRefinementLeaf_open_iff
#check bsd_fullyRefinedLeavesFromIds
#check bsd_fullyRefinedLeavesFromIds_count
#check bsd_openLeavesFromIds_count
#check bsd_closedLeavesFromIds_count

/-! ## Partial closure audit -/
#check ClosureAuditStatus
#check ClosureAuditEntry
#check ClosureAuditStatus.isOpen
#check ClosureAuditStatus.isKnownButUninternalized
#check ClosureAuditStatus.isStructuralCandidate
#check ClosureAuditStatus.isClosed
#check selmerFinite_knownButUninternalized
#check mordellWeilToSelmerInjection_structuralCandidate
#check shaGlobalFiniteness_staysOpen
#check higherEulerSystems_stayOpen
#check bsd_partialClosureAudit
#check shaGlobalFiniteness_audit_is_open
#check selmerFinite_audit_is_knownButUninternalized
#check mordellWeilInjection_audit_is_structuralCandidate
#check higherEulerSystems_audit_is_open

/-! ## Audit-registry counts -/
#check ClosureAuditEntry.isOpen
#check ClosureAuditEntry.isKnownButUninternalized
#check ClosureAuditEntry.isStructuralCandidate
#check ClosureAuditEntry.isClosed
#check closureAudit_openCount
#check closureAudit_knownButUninternalizedCount
#check closureAudit_structuralCandidateCount
#check closureAudit_closedCount
#check bsd_partialClosureAudit_openCount
#check bsd_partialClosureAudit_knownButUninternalizedCount
#check bsd_partialClosureAudit_structuralCandidateCount
#check bsd_partialClosureAudit_closedCount
#check bsd_partialClosureAudit_partition_counts

/-! ## Pending audit registry -/
#check PendingAuditEntry
#check selmerShaSurjection_pendingAudit
#check selmerShaExactness_pendingAudit
#check bsdLeadingCoefficientFormula_pendingAudit
#check bsdRankOrderCompatibility_pendingAudit
#check higherEulerNormCompatibility_pendingAudit
#check higherKolyvaginLocalRelations_pendingAudit
#check higherKolyvaginDerivativeLaw_pendingAudit
#check higherRankRegulatorCompatibility_pendingAudit
#check higherRankSelmerControl_pendingAudit
#check higherRankAnalyticRankCompatibility_pendingAudit
#check bsd_pendingClosureAudit
#check pendingAuditCount
#check bsd_pendingClosureAudit_count
#check bsd_partialAudit_is_not_exhaustive

/-! ## V4 typed audit coverage -/
#check AuditCoverage
#check shaGlobalFiniteness_auditCoverage
#check mordellWeilInjection_auditCoverage
#check higherEulerSystems_auditCoverage
#check selmerFinite_auditCoverage
#check bsd_auditCoverage
#check auditCoverageCoveredLeaves
#check bsd_auditCoveredLeaves
#check bsd_auditCoveredLeaves_eq_flatten
#check bsd_pendingAuditLeafIds
#check bsd_auditCoveredLeaves_count
#check bsd_pendingAuditLeafIds_count
#check bsd_typedCoverage_count_summary
#check bsd_typedCoverage_count_matches_openLeafCount

/-! ## V4 typed coverage consistency -/
#check bsd_typedCoverage_disjoint
#check bsd_auditCoveredLeaves_subset_open
#check bsd_pendingAuditLeafIds_subset_open
#check bsd_openLeafIds_covered_or_pending
#check bsd_typedCoverage_covers_openLeafIds
#check bsd_auditCoveredLeaves_nodup
#check bsd_pendingAuditLeafIds_nodup
#check bsd_openLeafIds_nodup

/-! ## V4 leaf-indexed partial-audit lookup -/
#check BSDLeafId.partialClosureAuditStatus
#check partialClosureAuditStatus_shaFinite
#check partialClosureAuditStatus_shaSelmerInjection
#check partialClosureAuditStatus_selmerSurjection_pending
#check partialClosureAuditStatus_higherRankSelmerControl
#check partialClosureAuditStatus_isSome_iff_covered
#check partialClosureAuditStatus_isNone_iff_uncovered

/-! ## Closeability audit -/
#check CloseabilityStatus
#check CloseabilityAuditEntry
#check CloseabilityStatus.isMathematicallyOpen
#check CloseabilityStatus.isTechnicallyHard
#check CloseabilityStatus.isTechnicallyHeavy
#check CloseabilityStatus.isBlockedByModeling
#check CloseabilityStatus.isCloseableNow
#check shaGlobalFiniteness_mathematicallyOpen
#check higherEulerSystems_mathematicallyOpen
#check selmerFinite_technicallyHard
#check mordellWeilToSelmerInjection_technicallyHeavy
#check selmerShaExactness_blockedByModeling
#check bsdLeadingCoefficientFormula_mathematicallyOpen
#check bsdRankOrderCompatibility_mathematicallyOpen
#check bsd_closeabilityAudit
#check closeabilityCountBy
#check bsd_closeabilityAudit_mathematicallyOpenCount
#check bsd_closeabilityAudit_technicallyHardCount
#check bsd_closeabilityAudit_technicallyHeavyCount
#check bsd_closeabilityAudit_blockedByModelingCount
#check bsd_closeabilityAudit_closeableNowCount
#check bsd_closeabilityAudit_partition_counts

/-! ## Closeability registry hygiene -/
#check CloseabilityRegistryHygieneClean
#check bsd_closeabilityAudit_hygieneClean
#check bsd_closeabilityAudit_has_no_closeableNow

/-! ## V4 typed closeability coverage -/
#check CloseabilityCoverage
#check shaGlobalFiniteness_closeabilityCoverage
#check higherEulerSystems_closeabilityCoverage
#check bsdLeadingCoefficientFormula_closeabilityCoverage
#check bsdRankOrderCompatibility_closeabilityCoverage
#check selmerFinite_closeabilityCoverage
#check mordellWeilInjection_closeabilityCoverage
#check selmerShaExactness_closeabilityCoverage
#check bsd_closeabilityCoverage
#check closeabilityCoverageCoveredLeaves
#check bsd_closeabilityCoveredLeaves
#check bsd_closeabilityCoveredLeaves_eq_flatten
#check bsd_closeabilityCoveredLeaves_count
#check bsd_closeabilityCoveredLeaves_nodup
#check bsd_closeabilityCoverage_subset_open
#check bsd_closeabilityCoverage_covers_openLeafIds

/-! ## V4 per-status typed-leaf attribution -/
#check bsd_closeabilityMathematicallyOpenLeafIds
#check bsd_closeabilityTechnicallyHardLeafIds
#check bsd_closeabilityTechnicallyHeavyLeafIds
#check bsd_closeabilityBlockedByModelingLeafIds
#check bsd_closeabilityCloseableNowLeafIds
#check bsd_closeabilityMathematicallyOpenLeafIds_count
#check bsd_closeabilityTechnicallyHardLeafIds_count
#check bsd_closeabilityTechnicallyHeavyLeafIds_count
#check bsd_closeabilityBlockedByModelingLeafIds_count
#check bsd_closeabilityCloseableNowLeafIds_count
#check bsd_closeabilityPerStatusCounts_sum

/-! ## V4 leaf-indexed closeability lookup -/
#check BSDLeafId.closeabilityStatus
#check closeabilityStatus_shaFinite
#check closeabilityStatus_selmerInjection
#check closeabilityStatus_selmerExactness
#check closeabilityStatus_torsion_closedLeaf_none
#check closeabilityStatus_some_of_openLeaf
#check closeabilityStatus_none_of_closedLeaf

/-! ## V5 branch-leaf registry -/
#check BridgeCMethodBranch
#check BranchLeaf
#check BranchLeaf.IsOpen
#check BranchLeaf.IsClosed
#check HPLeafId
#check HPLeafId.status
#check HPLeafId.label
#check HPLeafId.toBranchLeaf
#check hp_closedLeafIds
#check hp_openLeafIds
#check hp_allLeafIds
#check hp_closedLeafIds_count
#check hp_openLeafIds_count
#check hp_allLeafIds_count
#check ZetaLeafId
#check ZetaLeafId.status
#check ZetaLeafId.label
#check ZetaLeafId.toBranchLeaf
#check zeta_closedLeafIds
#check zeta_openLeafIds
#check zeta_allLeafIds
#check zeta_closedLeafIds_count
#check zeta_openLeafIds_count
#check zeta_allLeafIds_count
#check FreezingLeafId
#check FreezingLeafId.status
#check FreezingLeafId.label
#check FreezingLeafId.toBranchLeaf
#check freezing_closedLeafIds
#check freezing_openLeafIds
#check freezing_allLeafIds
#check freezing_closedLeafIds_count
#check freezing_openLeafIds_count
#check freezing_allLeafIds_count
#check BSDLeafId.toBranchLeaf
#check BridgeCAnyLeafId
#check BridgeCAnyLeafId.branch
#check BridgeCAnyLeafId.status
#check BridgeCAnyLeafId.toBranchLeaf
#check bridgeC_allHPLeafIds
#check bridgeC_allZetaLeafIds
#check bridgeC_allBSDLeafIds
#check bridgeC_allFreezingLeafIds
#check bridgeC_allLeafIds
#check bridgeC_allLeafIds_count
#check BridgeCBranchLeafProfile
#check hp_branchLeafProfile
#check zeta_branchLeafProfile
#check bsd_branchLeafProfile
#check freezing_branchLeafProfile
#check bridgeC_branchLeafProfiles
#check hp_branchLeafProfile_openCount
#check hp_branchLeafProfile_closedCount
#check zeta_branchLeafProfile_openCount
#check zeta_branchLeafProfile_closedCount
#check bsd_branchLeafProfile_openCount
#check bsd_branchLeafProfile_closedCount
#check freezing_branchLeafProfile_openCount
#check freezing_branchLeafProfile_closedCount

/-! ## Bridge C generality registry -/
#check BridgeCBranch
#check BridgeCBranch.isInternalBSD
#check BridgeCBranch.isExternalReference
#check BridgeCBranch.label
#check BridgeCBranchProfile
#check bridgeC_HP_profile
#check bridgeC_zeta_profile
#check bridgeC_BSD_profile
#check bridgeC_generality_registry
#check bridgeC_BSD_profile_internal
#check bridgeC_HP_profile_external
#check bridgeC_zeta_profile_external

/-! ## Profile and constraint triangle -/
#check BSDBridgeCProfile
#check bsdBridgeCProfile_has_bridgeC
#check bsdBridgeCProfile_has_whoWhere
#check bsdBridgeCProfile_has_encode
#check bsdBridgeCProfile_has_decode
#check bsdBridgeCProfile_has_logDeriv
#check bsdBridgeCProfile_has_higherRankSocket_as_hypothesis
#check bsdBridgeCProfile_whoBundle
#check bsdBridgeCProfile_whereBundle
#check bsdBridgeCProfile_compatibilityBundle
#check BSDConstraintTriangle
#check bsdBridgeCProfile_constraintTriangle

end BSDBridgeC
