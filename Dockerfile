FROM php:8.0-cli-alpine

# Install PHP CodeSniffer
ARG PHPCS_RELEASE="3.11.3"

RUN curl -OL https://github.com/PHPCSStandards/PHP_CodeSniffer/releases/download/${PHPCS_RELEASE}/phpcs.phar \
    && mv phpcs.phar /usr/local/bin/phpcs \
    && chmod +x /usr/local/bin/phpcs

# Install the PHPCompatibility standard
ARG PHPCOMP_RELEASE="develop"
ARG PHPCSUtils_RELEASE="develop"
RUN set -eux &&\
    apk --no-cache add git &&\
    mkdir -p "/opt/" &&\
    cd "/opt/" &&\
    git clone -v --single-branch --depth 1 https://github.com/PHPCompatibility/PHPCompatibility.git --branch $PHPCOMP_RELEASE &&\
    git clone -v --single-branch --depth 1 https://github.com/PHPCSStandards/PHPCSUtils.git --branch $PHPCSUtils_RELEASE &&\
    rm -rf PHPCompatibility/.git &&\
    rm -rf PHPCSUtils/.git &&\
    apk del git

# Configure phpcs defaults
RUN phpcs --config-set installed_paths /opt/PHPCompatibility,/opt/PHPCSUtils &&\
    phpcs --config-set default_standard PHPCompatibility &&\
    phpcs --config-set testVersion 8.0 &&\
    phpcs --config-set report_width 120

# Configure PHP with all the memory we might need (unlimited)
RUN echo "memory_limit = -1" >> /usr/local/etc/php/conf.d/memory.ini

WORKDIR /mnt/src

ENTRYPOINT ["/usr/local/bin/phpcs"]

CMD ["-p", "--colors", "."]
