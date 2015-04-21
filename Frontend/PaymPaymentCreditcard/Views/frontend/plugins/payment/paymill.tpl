
<link rel = "stylesheet" type = "text/css" href = "{link file='frontend/_resources/paymill_styles.css'}" />
<script type = "text/javascript" >
    var PAYMILL_PUBLIC_KEY = '{$publicKey}';
    var VALIDATE_CVC = true;
    var ActiveBrands = {$CreditcardBrands|@json_encode};
    var API_ERRORS = new Array();
    var paymilliFrame = {$paymillPCI};
    API_ERRORS["PAYMILL_internal_server_error"] = '{s namespace=Paymill name=PAYMILL_internal_server_error}{/s}';
    API_ERRORS["PAYMILL_invalid_public_key"] = '{s namespace=Paymill name=PAYMILL_invalid_public_key}{/s}';
    API_ERRORS["PAYMILL_invalid_payment_data"] = '{s namespace=Paymill name=PAYMILL_invalid_payment_data}{/s}';
    API_ERRORS["PAYMILL_unknown_error"] = '{s namespace=Paymill name=PAYMILL_unknown_error}{/s}';
    API_ERRORS["PAYMILL_3ds_cancelled"] = '{s namespace=Paymill name=PAYMILL_3ds_cancelled}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_number"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_number}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_exp_year"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_exp_year}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_exp_month"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_exp_month}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_exp"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_exp}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_cvc"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_cvc}{/s}';
    API_ERRORS["PAYMILL_field_invalid_card_holder"] = '{s namespace=Paymill name=PAYMILL_field_invalid_card_holder}{/s}';
    API_ERRORS["PAYMILL_field_invalid_amount_int"] = '{s namespace=Paymill name=PAYMILL_field_invalid_amount_int}{/s}';
    API_ERRORS["PAYMILL_field_field_invalid_amount"] = '{s namespace=Paymill name=PAYMILL_field_field_invalid_amount}{/s}';
    API_ERRORS["PAYMILL_field_field_field_invalid_currency"] = '{s namespace=Paymill name=PAYMILL_field_field_field_invalid_currency}{/s}';
    API_ERRORS["PAYMILL_field_invalid_account_number"] = '{s namespace=Paymill name=PAYMILL_field_invalid_account_number}{/s}';
    API_ERRORS["PAYMILL_field_invalid_account_holder"] = '{s namespace=Paymill name=PAYMILL_field_invalid_account_holder}{/s}';
    API_ERRORS["PAYMILL_field_invalid_bank_code"] = '{s namespace=Paymill name=PAYMILL_field_invalid_bank_code}{/s}';
    API_ERRORS["PAYMILL_field_invalid_iban"] = '{s namespace=Paymill name=PAYMILL_field_invalid_iban}{/s}';
    API_ERRORS["PAYMILL_field_invalid_bic"] = '{s namespace=Paymill name=PAYMILL_field_invalid_bic}{/s}';
    API_ERRORS["PAYMILL_field_invalid_country"] = '{s namespace=Paymill name=PAYMILL_field_invalid_country}{/s}';
    API_ERRORS["PAYMILL_field_invalid_bank_data"] = '{s namespace=Paymill name=PAYMILL_field_invalid_bank_data}{/s}';
</script >
<script type = "text/javascript" src = "https://bridge.paymill.com/dss3" ></script >
<script type = "text/javascript" src = "{link file='frontend/_resources/javascript/Iban.js'}" ></script >
<script type = "text/javascript" src = "{link file='frontend/_resources/javascript/BrandDetection.js'}" ></script >
<script type = "text/javascript" >
    function debug(message)
    {
        {if $debug}
            console.log("[" + getPayment() + "] " + message);
        {/if}
    }

    function getPayment()
    {
        return "{$sPayment.name}";
    }
    function hasDummyData()
    {
        if (getPayment() === 'paymillcc') {
            var cardNumber = $('#card-number').val();
            var validMonth = $('#card-expiry-month').val();
            var validYear = $('#card-expiry-year').val();

            debug(cardNumber);
            debug(validMonth);
            debug(validYear);

            if ((cardNumber === "" || validMonth === "" || validYear === "") || ("{$paymillCardNumber}" !== cardNumber) || ("{$paymillMonth}" !== validMonth) || ("{$paymillYear}" !== validYear)) {
                debug("Creditcard information found. New Information will be used. Token should be getting generated.");
                return false;
            }

        }

        if (getPayment() === 'paymilldebit') {
            var iban = $('#paymill_iban').val();
            var bic = $('#paymill_bic').val();
            if ((iban === "" || bic === "") || ("{$paymillAccountNumber}" !== iban) || ("{$paymillBankCode}" !== bic)) {
                debug("Direct Debit information found. New Information will be used. Token should be getting generated.");
                return false;
            }
        }
        debug("Fast Checkout Data found and not altered. Will process with given data. Validation will be skipped.");
        return true;
    }
    function validate()
    {
        debug("Paymill handler triggered");
        var errorsCc = $("#errorsCc");
        errorsCc.parent().hide();
        errorsCc.html("");
        var errorsElv = $("#errorsElv");
        errorsElv.parent().hide();
        errorsElv.html("");
        var result = true;
        if (getPayment() === 'paymillcc' && paymilliFrame) { //If CC and not iFrame Solution
            if (!paymill.validateHolder($('#card-holder').val())) {
                errorsCc.append("<li>{s namespace=Paymill name=feedback_error_creditcard_holder}Please enter the cardholders name.{/s}</li>");
                result = false;
            }
            if (!paymill.validateCardNumber($('#card-number').val())) {
                errorsCc.append("<li>{s namespace=Paymill name=feedback_error_creditcard_number}Please enter a valid creditcardnumber.{/s}</li>");
                result = false;
            }
            if (!paymill.validateCvc($('#card-cvc').val())) {
                if (VALIDATE_CVC) {
                    errorsCc.append("<li>{s namespace=Paymill name=feedback_error_creditcard_cvc}Please enter a valid securecode (see back of creditcard).{/s}</li>");
                    result = false;
                }
            }
            if (/^\d\d$/.test($('#card-expiry-year').val())) {
                $('#card-expiry-year').val("20" + $('#card-expiry-year').val());
            }
            if (!paymill.validateExpiry($('#card-expiry-month').val(), $('#card-expiry-year').val())) {
                errorsCc.append("<li>{s namespace=Paymill name=feedback_error_creditcard_valid}The expiry date is invalid.{/s}</li>");
                result = false;
            }
            if (!result) {
                errorsCc.parent().show();
            } else {
                debug("Validations successful");
            }
        } else {
            result = true;
            debug("No validation, because of iFrame Solution.");
        }
        if (getPayment() === 'paymilldebit') { //If ELV
            if (!paymill.validateHolder($('#paymill_accountholder').val())) {
                errorsElv.append("<li>{s namespace=Paymill name=feedback_error_directdebit_holder}Please enter the account name.{/s}</li>");
                result = false;
            }
            if (isSepa()) {
                iban = new Iban();
                if (!iban.validate($('#paymill_iban').val())) {
                    errorsElv.append("<li>{s namespace=Paymill name=feedback_error_sepa_iban}Please enter a valid iban{/s}</li>");
                    result = false;
                }

                if ($('#paymill_bic').val() === '') {
                    errorsElv.append("<li>{s namespace=Paymill name=feedback_error_sepa_bic}Please a valid bic.{/s}</li>");
                    result = false;
                }
            } else {
                if (!paymill.validateAccountNumber($('#paymill_iban').val())) {
                    errorsElv.append("<li>{s namespace=Paymill name=feedback_error_directdebit_number}Please enter a valid account number{/s}</li>");
                    result = false;
                }

                if (!paymill.validateBankCode($('#paymill_bic').val())) {
                    errorsElv.append("<li>{s namespace=Paymill name=feedback_error_directdebit_bankcode}Please a valid bankcode.{/s}</li>");
                    result = false;
                }
            }
            if (!result) {
                errorsElv.parent().show();
            } else {
                debug("Validations successful");
            }
        }
        return result;
    }
$(document).ready(function ()
    {
        var paymill_form_id = "payment_mean{$payment_mean.id}";
    $('#card-number').keyup(function ()
        {
            $("#card-number")[0].className = $("#card-number")[0].className.replace(/paymill-card-number-.*/g, '');
            var detector = new BrandDetection();
            var brand = detector.detect($('#card-number').val());

            if (detector.validate($('#card-number').val())) {
                suffix = '';
            } else {
                suffix = '-temp';
            }
        if($.inArray(brand, ActiveBrands) !== -1){
                $('#card-number').addClass("paymill-card-number-" + brand + suffix);
            }
        });

    $("#basketButton").click(function ()
        {
            if ($('#' + paymill_form_id).attr("checked") === "checked") {
                if ($("input[type='checkbox'][name='sAGB']").length) {
                    if ($("input[type='checkbox'][name='sAGB']").attr('checked') !== "checked") {
                        $("input[type='checkbox'][name='sAGB']").next('label').addClass('instyle_error');
                        $('html, body').animate({
                            scrollTop: $("input[type='checkbox'][name='sAGB']").offset().top - 100
                        }, 1000);
                        return false;
                    }
                }
                $("#basketButton").prop( "disabled",true);
                if (hasDummyData()) {
                    var form = $("#basketButton").closest('form');
                    form.get(0).submit();
                } else {
                    if (validate()) {
                        try {
                            if (getPayment() === 'paymillcc' && ) { //If CC and not iFrame Solution
                                if (VALIDATE_CVC) {
                                    paymill.createToken({
                                    number:     $('#card-number').val(),
                                        cardholder: $('#card-holder').val(),
                                    exp_month:  $('#card-expiry-month').val(),
                                    exp_year:   $('#card-expiry-year').val(),
                                    cvc:        $('#card-cvc').val(),
                                        amount_int: '{$tokenAmount}',
                                    currency:   '{config name=currency|upper}'
                                    }, PaymillResponseHandler);
                                } else {
                                    cvcInput = $('#card-cvc').val();
                                    paymill.createToken({
                                    number:     $('#card-number').val(),
                                        cardholder: $('#card-holder').val(),
                                    exp_month:  $('#card-expiry-month').val(),
                                    exp_year:   $('#card-expiry-year').val(),
                                    cvc:        cvcInput === "" ? "000" : cvcInput,
                                        amount_int: '{$tokenAmount}',
                                    currency:   '{config name=currency|upper}'
                                    }, PaymillResponseHandler);
                                }
                            } else {
                                    paymill.createToken({
                                        amount_int: '{$tokenAmount}',
                                        currency:   '{config name=currency|upper}'
                                    }, PaymillResponseHandler);
                            }
                            if (getPayment() === 'paymilldebit') { //If ELV
                                if (isSepa()) {
                                    paymill.createToken({
                                    iban:        $('#paymill_iban').val(),
                                    bic:          $('#paymill_bic').val(),
                                        accountholder: $('#paymill_accountholder').val()
                                    }, PaymillResponseHandler);
                                } else {
                                    paymill.createToken({
                                    number:        $('#paymill_iban').val(),
                                    bank:          $('#paymill_bic').val(),
                                        accountholder: $('#paymill_accountholder').val()
                                    }, PaymillResponseHandler);
                                }
                            }
                        } catch (e) {
                            alert("Ein Fehler ist aufgetreten: " + e);
                            $("#basketButton").prop( "disabled",false);
                        }
                    } else {
                        $("#basketButton").prop( "disabled",false);
                        if (getPayment() === 'paymillcc') {
                            $('html, body').animate({
                                scrollTop: $("#errorsCc").offset().top - 100
                            }, 1000);
                        }
                        if (getPayment() === 'paymilldebit') {
                            $('html, body').animate({
                                scrollTop: $("#errorsElv").offset().top - 100
                            }, 1000);
                        }
                    }
                }
                return false;
            }
        });
    });
    function PaymillResponseHandler(error, result)
    {
        debug("Started Paymill response handler");
        if (error) {
            errorText = API_ERRORS["PAYMILL_" + error.apierror];
            debug(errorText);
            alert(errorText);
            $("#basketButton").prop( "disabled",false);
        } else {
            debug("Received token from Paymill API: " + result.token);
            var form = $("#basketButton").closest('form');
            var token = result.token;
            form.append("<input type='hidden' name='paymillToken' value='" + token + "'/>");
            form.get(0).submit();
        }
    }
    function isSepa() {
    var reg = new RegExp(/^\D\D/);
            return reg.test($('#paymill_iban').val());
    }
</script >

<div class = "error" style = "display: none" >
    {if $payment_mean.name == 'paymillcc'}
        <li >{s namespace=Paymill name=feedback_error_creditcard_parent}Please enter your credit card information. For security reason we will not save them on our system.{/s}</li >
        <ul id = "errorsCc" ></ul >
    {/if}

    {if $payment_mean.name == 'paymilldebit'}
        <li >{s namespace=Paymill name=feedback_error_directdebit_parent}Please enter your accountdata. For security reason we will not save them on our system.{/s}</li >
        <ul id = "errorsElv" ></ul >
    {/if}
</div >

    {if $Controller != "account"}
        <div class = "debit" id='paymillFormContainer'>
        {if $payment_mean.name == 'paymillcc'}
            {if {config name=paymillBrandIconAmex}}<div class="paymill-card-icon paymill-card-number-amex"></div>{/if}
            {if {config name=paymillBrandIconCartaSi}}<div class="paymill-card-icon paymill-card-number-carta-si"></div>{/if}
            {if {config name=paymillBrandIconCarteBleue}}<div class="paymill-card-icon paymill-card-number-carte-bleue"></div>{/if}
            {if {config name=paymillBrandIconDankort}}<div class="paymill-card-icon paymill-card-number-dankort"></div>{/if}
            {if {config name=paymillBrandIconDinersclub}}<div class="paymill-card-icon paymill-card-number-diners-club"></div>{/if}
            {if {config name=paymillBrandIconDiscover}}<div class="paymill-card-icon paymill-card-number-discover"></div>{/if}
            {if {config name=paymillBrandIconJcb}}<div class="paymill-card-icon paymill-card-number-jcb"></div>{/if}
            {if {config name=paymillBrandIconMaestro}}<div class="paymill-card-icon paymill-card-number-maestro"></div>{/if}
            {if {config name=paymillBrandIconMastercard}}<div class="paymill-card-icon paymill-card-number-mastercard"></div>{/if}
            {if {config name=paymillBrandIconVisa}}<div class="paymill-card-icon paymill-card-number-visa"></div>{/if}
            {if {config name=paymillBrandIconUnionpay}}<div class="paymill-card-icon paymill-card-number-china-unionpay"></div>{/if}
            {if $paymillPCI}
                {include file='frontend/plugins/payment/paymill_cc_saq_ep.tpl'}
            {else}
                {include file='frontend/plugins/payment/paymill_cc_saq.tpl'}
            {/if}
        {/if}

        {if $payment_mean.name == 'paymilldebit' }
            {include file='frontend/plugins/payment/paymill_debit.tpl'}
        {/if}
        </div >
    {/if}