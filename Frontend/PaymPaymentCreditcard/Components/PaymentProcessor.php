<?php

require_once dirname(__FILE__) . '/../lib/Services/Paymill/PaymentProcessor.php';

/**
 * This class stub allows the shop compliant usage of the paymill libs PaymentProcessor class
 *
 * @category   Shopware
 * @package    Shopware_Plugins
 * @subpackage Paymill
 * @author     Paymill
 */
class Shopware_Plugins_Frontend_PaymPaymentCreditcard_Components_PaymentProcessor extends Services_Paymill_PaymentProcessor
{
    public function __construct($params = null)
    {
        $swConfig = Shopware()->Plugins()->Frontend()->PaymPaymentCreditcard()->Config();
        $privateKey = trim($swConfig->get("privateKey"));
        $apiUrl = "https://api.paymill.com/v2/";
        $source = Shopware()->Plugins()->Frontend()->PaymPaymentCreditcard()->getVersion();
        $source .= "_shopware";
        $source .= "_" . Shopware()->Config()->get('version');
        $this->setSource($source);
        $loggingManager = new Shopware_Plugins_Frontend_PaymPaymentCreditcard_Components_LoggingManager();
        parent::__construct($privateKey, $apiUrl, null, $params, $loggingManager);
    }
}
