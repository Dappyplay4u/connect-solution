locals {
  required_tags = {
    business_application_id   = var.business_application_id
    cost_center               = var.cost_center
    created_by                = var.created_by
    technical_support_by      = var.technical_support_by
    application_group         = var.application_group
    technical_environment     = var.technical_environment
    security_data_application = var.security_data_application
    business_application_code = var.business_application_code
  }

  # ---------------------------------------------------------------------------
  # Instance resolution
  # ---------------------------------------------------------------------------
  resolved_instance_id = var.instance_id != null ? var.instance_id : data.aws_connect_instance.this[0].id

  # ---------------------------------------------------------------------------
  # Queue name prefix — mirrors the connect-queue module naming convention:
  #   <project_name>-<account>-connect-<lob>-<sdlc_env>-<aws_region_abbr>-<key>
  # ---------------------------------------------------------------------------
  queue_name_prefix = "${var.project_name}-${var.account}-connect-${var.lob}-${var.sdlc_env}-${var.aws_region_abbr}"

  # ---------------------------------------------------------------------------
  # Queue name lists — mirrors connect-queue/locals.tf
  # ---------------------------------------------------------------------------

  customer_care_queues = [
    "CC_CCF_ATMDebitCardAcctInfo",
    "CC_CCF_ATMDebitCardPINChange",
    "CC_CCF_BranchATMLoc",
    "CC_CCF_CardActivation",
    "CC_CCF_ConsNewAcct",
    "CC_CCF_DepAcctInfo",
    "CC_CCF_DigitalOther",
    "CC_CCF_DigitalZelleBillPay",
    "CC_CCF_FundsTransfer",
    "CC_CCF_FundsTransThresholdExceed",
    "CC_CCF_LostStolenATM",
    "CC_CCF_TruistMainOther",
    "CC_CCO_ATMDebitCardAcctInfo",
    "CC_CCO_ATMDebitCardPINChange",
    "CC_CCO_BusNewAcct",
    "CC_CCO_ConsNewAcct",
    "CC_CCO_DepAcctInfo",
    "CC_CCO_DigitalOther",
    "CC_CCO_DigitalZelleBillPay",
    "CC_CCO_FundsTransfer",
    "CC_CCO_LostStolenATM",
    "CC_CCO_TaxInterest",
    "CC_CCO_TruistMainOther",
  ]

  credit_card_queues = [
    "CC_CD1_CardAcctInfoFD",
    "CC_CD1_CardAcctInfoFD_PRM",
    "CC_CD1_CardPinChangeFD",
    "CC_CD2_CardAcctInfoFD",
    "CC_CD2_CardAcctInfoFD_PRM",
    "CC_CD2_CardPinChangeFD",
    "CC_CD3_CardAcctInfoFD",
    "CC_CD3_CardAcctInfoFD_PRM",
    "CC_CD3_CardPinChangeFD",
    "CC_CD4_CardAcctInfoFD",
    "CC_CD4_CardAcctInfoFD_PRM",
    "CC_CD4_CardPinChangeFD",
  ]

  loans_queues = [
    "CC_LNS_AcctInfo",
    "CC_LNS_ConsNewAcct",
    "CC_LNS_DepAcctInfo",
    "CC_LNS_FundsTransfer",
    "CC_LNS_PaymtInfo",
  ]

  digital_queues = [
    "CC_DIG_DigitalOther",
    "CC_DIG_DigitalZelleBillPay",
    "CC_DIG_MobileApp",
    "CC_DIG_OnlineBanking",
  ]

  premier_queues = [
    "CC_PRM_AcctInfo",
    "CC_PRM_CardAcctInfo",
    "CC_PRM_ConsNewAcct",
    "CC_PRM_FundsTransfer",
  ]

  spanish_queues = [
    "CC_SPA_ATMDebitCardAcctInfo",
    "CC_SPA_ConsNewAcct",
    "CC_SPA_DepAcctInfo",
    "CC_SPA_DigitalOther",
    "CC_SPA_FundsTransfer",
    "CC_SPA_TruistMainOther",
  ]

  fraud_security_queues = [
    "CC_SCC_CardFraud",
    "CC_SCC_DepAcctFraud",
    "CC_SCC_IdentityTheft",
    "CC_SCB_CardFraud",
    "CC_SCB_DepAcctFraud",
    "CC_SCB_IdentityTheft",
  ]

  business_commercial_queues = [
    "CC_BC1_AcctInfo",
    "CC_BC1_BusNewAcct",
    "CC_BC1_FundsTransfer",
    "CC_BC2_AcctInfo",
    "CC_BC2_BusNewAcct",
    "CC_BSC_AcctInfo",
    "CC_BSC_TechSupport",
    "CC_SDB_DigitalOther",
    "CC_SDB_OnlineBanking",
  ]

  special_routing_queues = [
    "WSC - Fraud Detection",
    "WSC - Transfer from TCC",
    "WSC - Truist IVR - Deposit",
    "WSC - Truist IVR - Digital",
    "WSC - Truist IVR - Fraud",
    "WSC - Truist IVR - General",
  ]

  all_queues = concat(
    local.customer_care_queues,
    local.credit_card_queues,
    local.loans_queues,
    local.digital_queues,
    local.premier_queues,
    local.spanish_queues,
    local.fraud_security_queues,
    local.business_commercial_queues,
    local.special_routing_queues,
  )

  # ---------------------------------------------------------------------------
  # Queues to look up — excludes any key in var.queues_to_skip.
  # Use queues_to_skip for queues that don't exist in Connect yet.
  # ---------------------------------------------------------------------------
  queues_to_lookup = [
    for q in local.all_queues : q
    if !contains(var.queues_to_skip, q)
  ]

  # ---------------------------------------------------------------------------
  # QUEUE-type quick connects — built from data source results.
  # One quick connect per looked-up queue. Skipped if transfer_to_queue_flow_id
  # is not provided.
  # ---------------------------------------------------------------------------
  queue_quick_connects = var.transfer_to_queue_flow_id != null ? {
    for q, ds in data.aws_connect_queue.this : q => {
      type            = "QUEUE"
      description     = "Transfer to queue: ${q}"
      contact_flow_id = var.transfer_to_queue_flow_id
      queue_id        = ds.queue_id
    }
  } : {}
}
