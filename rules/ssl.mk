define SSL_RULES
$(1).SSL_ORG ?= $(1)
$(1).SSL_DIR = $(1)/ssl
$(1).SSL_LEN ?= 1024
$(1).GEN_P = $(call GEN_P,$$($(1).SSL_DIR),$$(1))

$$(call $(1).GEN_P,ca_cert.conf):
	@echo TARGET $(1) GEN ca_cert.conf
	$(Q)mkdir -p $$(dir $$@)
	$(Q)echo '[req]' >> $$@
	$(Q)echo 'distinguished_name = req_distinguished_name' >> $$@
	$(Q)echo 'prompt = no' >> $$@
	$(Q)echo '' >> $$@
	$(Q)echo '[req_distinguished_name]' >> $$@
	$(Q)echo ' O = $$($(1).SSL_ORG) Certificate Authority' >> $$@
	$(Q)echo '' >> $$@

$$(call $(1).GEN_P,certs.conf):
	@echo TARGET $(1) GEN certs.conf
	$(Q)mkdir -p $$(dir $$@)
	$(Q)echo '[req]' >> $$@
	$(Q)echo 'distinguished_name = req_distinguished_name' >> $$@
	$(Q)echo 'prompt = no' >> $$@
	$(Q)echo '' >> $$@
	$(Q)echo '[req_distinguished_name]' >> $$@
	$(Q)echo ' O = $$($(1).SSL_ORG)' >> $$@
	$(Q)echo ' CN = 127.0.0.1' >> $$@
	$(Q)echo '' >> $$@

$$(call $(1).GEN_P,device_cert.conf):
	@echo TARGET $(1) GEN device_cert.conf
	$(Q)mkdir -p $$(dir $$@)
	$(Q)echo '[req]' >> $$@
	$(Q)echo 'distinguished_name = req_distinguished_name' >> $$@
	$(Q)echo 'prompt = no' >> $$@
	$(Q)echo '' >> $$@
	$(Q)echo '[req_distinguished_name]' >> $$@
	$(Q)echo ' O = $$($(1).SSL_ORG) Device Certificate' >> $$@
	$(Q)echo '' >> $$@

$$(call $(1).GEN_P,ca_key.pem):
	$(Q)mkdir -p $$(dir $$@)
	$(Q)openssl genrsa -out $$@ $$($(1).SSL_LEN)

$$(call $(1).GEN_P,ca_x509.pem): $$(call $(1).GEN_P,ca_x509.req) $$(call $(1).GEN_P,ca_key.pem)
	$(Q)openssl x509 -req -in $$< -out $$@ -sha1 -days 5000 -signkey $$(word 2,$$^)

$$(call $(1).GEN_P,ca_x509.req): $$(call $(1).GEN_P,ca_key.pem) $$(call $(1).GEN_P,ca_cert.conf)
	$(Q)openssl req -out $$@ -key $$< -new -config $$(word 2,$$^)

$$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).req): $$(call $(1).GEN_P,key_$$($(1).SSL_LEN).pem) $$(call $(1).GEN_P,certs.conf)
	$(Q)openssl req -out $$@ -key $$< -new -config $$(word 2,$$^)

$$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).pem): $$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).req) $$(call $(1).GEN_P,ca_x509.pem) $$(call $(1).GEN_P,ca_key.pem)
	$(Q)openssl x509 -req -in $$< -out $$@ -sha1 -CAcreateserial -days 5000 -CA $$(word 2,$$^) -CAkey $$(word 3,$$^)

$$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).cer): $$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).pem)
	$(Q)openssl x509 -in $$< -out $$@ -outform DER

$$(call $(1).GEN_P,key_$$($(1).SSL_LEN).pem):
	$(Q)mkdir -p $$(dir $$@)
	$(Q)openssl genrsa -out $$@ $$($(1).SSL_LEN)

$$(call $(1).GEN_P,key_$$($(1).SSL_LEN).key): $$(call $(1).GEN_P,key_$$($(1).SSL_LEN).pem)
	$(Q)openssl rsa -in $$< -out $$@ -outform DER

$(1).SRCS += \
  $$(call $(1).GEN_P,x509_$$($(1).SSL_LEN).cer)?symbol=default_certificate \
  $$(call $(1).GEN_P,key_$$($(1).SSL_LEN).key)?symbol=default_private_key

clean.lib.$(1): clean.ssl.$(1)
clean.ssl.$(1):
	$(Q)rm -rf $$(call $(1).GEN_P)
endef
