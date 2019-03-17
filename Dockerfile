FROM wordpress
LABEL maintainer "Masahiko Ebisuda<ebibibi@gmail.com>"

# ------------------------
# SSH Server support
# ------------------------
RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd

COPY sshd_config /etc/ssh/

EXPOSE 2222 80 443

#--------------------------
# Install wordpress plugins
#--------------------------
# これから使う`wget`と`unzip`を入れる
RUN apt-get update
RUN apt-get -y --force-yes -o Dpkg::Options::="--force-confdef" install wget unzip

# プラグインファイルの一時ダウンロード先
WORKDIR /tmp/wp-plugins

# プラグインファイルをダウンロード
RUN wget https://downloads.wordpress.org/plugin/really-simple-ssl.3.1.5.zip

RUN wget https://downloads.wordpress.org/plugin/akismet.4.1.1.zip
RUN wget https://downloads.wordpress.org/plugin/announcer.3.0.zip
RUN wget https://downloads.wordpress.org/plugin/drift.1.8.4.zip
RUN wget https://downloads.wordpress.org/plugin/ewww-image-optimizer.4.6.3.zip
RUN wget https://downloads.wordpress.org/plugin/google-sitemap-generator.4.1.0.zip
RUN wget https://downloads.wordpress.org/plugin/jetpack.7.1.1.zip
RUN wget https://downloads.wordpress.org/plugin/pixabay-images.zip
RUN wget https://downloads.wordpress.org/plugin/simple-feature-requests.zip
RUN wget https://downloads.wordpress.org/plugin/pubsubhubbub.3.0.2.zip
RUN wget https://downloads.wordpress.org/plugin/wordfence.7.2.3.zip
RUN wget https://downloads.wordpress.org/plugin/wordpress-social-login.zip
RUN wget https://downloads.wordpress.org/plugin/wp-azure-offload.1.0.zip
RUN wget https://downloads.wordpress.org/plugin/wp-fastest-cache.0.8.9.1.zip
RUN wget https://downloads.wordpress.org/plugin/wp-multibyte-patch.2.8.2.zip
RUN wget https://downloads.wordpress.org/plugin/wp-mail-smtp.zip
RUN wget https://downloads.wordpress.org/plugin/wp-postratings.1.86.2.zip



# プラグインをWordPressのプラグインディレクトリに解凍する
RUN unzip -o './*.zip' -d /usr/src/wordpress/wp-content/plugins
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content

# 一時ダウンロード先内の全ファイルの削除
RUN rm -rf '/tmp/wp-plugins'

# 戻る
WORKDIR /var/www/html

#------------------------
# Install Wordpress theme
#------------------------

# テーマファイルの一時ダウンロード先
WORKDIR /tmp/wp-themes

ENV cocoonversion=1.6.8

# テーマファイルをダウンロード
RUN wget https://github.com/ebibibi/appservice-wordpress/raw/master/Themes/cocoon-child-master.zip
RUN wget https://github.com/ebibibi/wordpress-cocoon/raw/master/Themes/cocoon-master-${cocoonversion}.zip
# get latest them from https://wp-cocoon.com/downloads/

# テーマをWordPressのテーマディレクトリに解凍する
RUN unzip './*.zip' -d /usr/src/wordpress/wp-content/themes
RUN chown -R www-data:www-data /usr/src/wordpress/wp-content

# 一時ダウンロード先内の全ファイルの削除
RUN rm -rf '/tmp/wp-themes'

# 戻る
WORKDIR /var/www/html


#------------------------
# 実行
#------------------------
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh 
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]