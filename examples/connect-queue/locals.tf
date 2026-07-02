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
  # 1. Customer Care (CC_CCF / CC_CCO)
  # ---------------------------------------------------------------------------
  customer_care_queues = [
    # CCF – Customer Care Front
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
    # CCO – Customer Care Overflow
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

  # ---------------------------------------------------------------------------
  # 2. Credit Card Services (CD1 / CD2 / CD3 / CD4)
  # ---------------------------------------------------------------------------
  credit_card_queues = [
    # CD1 – TSYS
    "CC_CD1_CardAcctInfoFD",
    "CC_CD1_CardAcctInfoFD_PRM",
    "CC_CD1_CardPinChangeFD",
    # CD2 – Hybrid
    "CC_CD2_CardAcctInfoFD",
    "CC_CD2_CardAcctInfoFD_PRM",
    "CC_CD2_CardPinChangeFD",
    # CD3 – FIS
    "CC_CD3_CardAcctInfoFD",
    "CC_CD3_CardAcctInfoFD_PRM",
    "CC_CD3_CardPinChangeFD",
    # CD4 – Specialized
    "CC_CD4_CardAcctInfoFD",
    "CC_CD4_CardAcctInfoFD_PRM",
    "CC_CD4_CardPinChangeFD",
  ]

  # ---------------------------------------------------------------------------
  # 3. Loans (CC_LNS)
  # ---------------------------------------------------------------------------
  loans_queues = [
    "CC_LNS_AcctInfo",
    "CC_LNS_ConsNewAcct",
    "CC_LNS_DepAcctInfo",
    "CC_LNS_FundsTransfer",
    "CC_LNS_PaymtInfo",
  ]

  # ---------------------------------------------------------------------------
  # 4. Digital / Online Support (CC_DIG)
  # ---------------------------------------------------------------------------
  digital_queues = [
    "CC_DIG_DigitalOther",
    "CC_DIG_DigitalZelleBillPay",
    "CC_DIG_MobileApp",
    "CC_DIG_OnlineBanking",
  ]

  # ---------------------------------------------------------------------------
  # 5. Premier Customer Services (CC_PRM)
  # ---------------------------------------------------------------------------
  premier_queues = [
    "CC_PRM_AcctInfo",
    "CC_PRM_CardAcctInfo",
    "CC_PRM_ConsNewAcct",
    "CC_PRM_FundsTransfer",
  ]

  # ---------------------------------------------------------------------------
  # 6. Spanish Language Support (CC_SPA)
  # ---------------------------------------------------------------------------
  spanish_queues = [
    "CC_SPA_ATMDebitCardAcctInfo",
    "CC_SPA_ConsNewAcct",
    "CC_SPA_DepAcctInfo",
    "CC_SPA_DigitalOther",
    "CC_SPA_FundsTransfer",
    "CC_SPA_TruistMainOther",
  ]

  # ---------------------------------------------------------------------------
  # 7. Fraud & Security (CC_SCC / CC_SCB)
  # ---------------------------------------------------------------------------
  fraud_security_queues = [
    # SCC
    "CC_SCC_CardFraud",
    "CC_SCC_DepAcctFraud",
    "CC_SCC_IdentityTheft",
    # SCB
    "CC_SCB_CardFraud",
    "CC_SCB_DepAcctFraud",
    "CC_SCB_IdentityTheft",
  ]

  # ---------------------------------------------------------------------------
  # 8. Business & Commercial Services (CC_BC1 / CC_BC2 / CC_BSC / CC_SDB)
  # ---------------------------------------------------------------------------
  business_commercial_queues = [
    # BC1 – Business Care
    "CC_BC1_AcctInfo",
    "CC_BC1_BusNewAcct",
    "CC_BC1_FundsTransfer",
    # BC2 – Business Care
    "CC_BC2_AcctInfo",
    "CC_BC2_BusNewAcct",
    # BSC – Business Support
    "CC_BSC_AcctInfo",
    "CC_BSC_TechSupport",
    # SDB – Small Business Digital
    "CC_SDB_DigitalOther",
    "CC_SDB_OnlineBanking",
  ]

  # ---------------------------------------------------------------------------
  # 9. Special Routing / IVR (WSC)
  # ---------------------------------------------------------------------------
  special_routing_queues = [
    "WSC - Fraud Detection",
    "WSC - Transfer from TCC",
    "WSC - Truist IVR - Deposit",
    "WSC - Truist IVR - Digital",
    "WSC - Truist IVR - Fraud",
    "WSC - Truist IVR - General",
  ]

  # ---------------------------------------------------------------------------
  # Master list — all queues flattened
  # ---------------------------------------------------------------------------
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
  # Category display labels — used for tagging and reporting
  # ---------------------------------------------------------------------------
  queue_category_descriptions = {
    customer_care_queues       = "Customer Care"
    credit_card_queues         = "Credit Card Services"
    loans_queues               = "Loan Services"
    digital_queues             = "Digital / Online Support"
    premier_queues             = "Premier Customer Services"
    spanish_queues             = "Spanish Language Support"
    fraud_security_queues      = "Fraud & Security"
    business_commercial_queues = "Business & Commercial Services"
    special_routing_queues     = "IVR / Routing / System"
  }

  # ---------------------------------------------------------------------------
  # Queue → category map
  # Maps each queue key to its owning category for downstream logic
  # (routing, reporting, tagging)
  # ---------------------------------------------------------------------------
  queue_category_map = {
    for q in local.all_queues : q => (
      contains(local.customer_care_queues,       q) ? "customer_care_queues" :
      contains(local.credit_card_queues,         q) ? "credit_card_queues" :
      contains(local.loans_queues,               q) ? "loans_queues" :
      contains(local.digital_queues,             q) ? "digital_queues" :
      contains(local.premier_queues,             q) ? "premier_queues" :
      contains(local.spanish_queues,             q) ? "spanish_queues" :
      contains(local.fraud_security_queues,      q) ? "fraud_security_queues" :
      contains(local.business_commercial_queues, q) ? "business_commercial_queues" :
      contains(local.special_routing_queues,     q) ? "special_routing_queues" :
      "unknown"
    )
  }

  # ---------------------------------------------------------------------------
  # Auto-generated human-readable queue descriptions
  #
  # For CC_ queues:
  #   Prefix (first two underscore segments, e.g. CC_CCF) is looked up to
  #   produce a category label. Remaining segments are joined, spaced, and
  #   expanded for common abbreviations.
  #
  # For WSC queues:
  #   Name contains spaces/dashes — falls through to the raw queue key.
  # ---------------------------------------------------------------------------
  queue_descriptions = {
    for q in local.all_queues : q => trimspace(
      join(" - ", compact([
        # Prefix label
        lookup(
          {
            CC_CCF = "Customer Care - Frontline"
            CC_CCO = "Customer Care - Overflow"
            CC_CD1 = "Card Services - TSYS"
            CC_CD2 = "Card Services - Hybrid"
            CC_CD3 = "Card Services - FIS"
            CC_CD4 = "Card Services - Specialized"
            CC_LNS = "Loan Services"
            CC_DIG = "Digital Support"
            CC_PRM = "Premier Support"
            CC_SPA = "Spanish Support"
            CC_SCC = "Fraud / Security"
            CC_SCB = "Fraud / Security"
            CC_BC1 = "Business Care"
            CC_BC2 = "Business Care"
            CC_BSC = "Business Support"
            CC_SDB = "Small Business Digital"
          },
          length(split("_", q)) >= 2 ? join("_", [split("_", q)[0], split("_", q)[1]]) : "",
          null
        ),
        # Functional label — expanded segments after the CC_XXX prefix
        replace(
          length(split("_", q)) >= 2 && startswith(q, "CC_") ? replace(
            replace(
              replace(
                join(
                  " ",
                  slice(
                    split("_", replace(q, "CC_", "")),
                    1,
                    length(split("_", replace(q, "CC_", "")))
                  )
                ),
                "AcctInfo", "Account Info"
              ),
              "Pymnt", "Payment"
            ),
            "DispTrans", "Disputed Transaction"
          ) : q,
          "FCI", ""
        ),
      ]))
    )
  }
}
