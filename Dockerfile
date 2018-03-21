FROM wordpress

# ------------------------
# Enable mod_rewrite
# ------------------------
RUN a2enmod rewrite

# ------------------------
# SSH Server support
# ------------------------
RUN apt-get update \ 
  && apt-get install -y --no-install-recommends openssh-server \
  && echo "root:Docker!" | chpasswd

COPY sshd_config /etc/ssh/
EXPOSE 2222

COPY init_container.sh /bin/
RUN chmod 755 /bin/init_container.sh 
CMD ["sh", "/bin/init_container.sh"]