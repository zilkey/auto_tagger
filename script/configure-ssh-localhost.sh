#!/bin/bash

SSH_DIR=$HOME/.ssh

if [ ! -d $SSH_DIR ]
then
  mkdir -p $SSH_DIR
  chmod 700 $SSH_DIR
fi

if [ -f $SSH_DIR/id_dsa.pub ]
then
  PUBLIC_KEY=$SSH_DIR/id_dsa.pub
else
  PUBLIC_KEY=$SSH_DIR/id_rsa.pub

  if [ ! -f $PUBLIC_KEY ]
  then
    ssh-keygen -t rsa -f $SSH_DIR/id_rsa -P '' -q
  fi
fi

cat $PUBLIC_KEY >> $SSH_DIR/authorized_keys
chmod 600 $SSH_DIR/authorized_keys
