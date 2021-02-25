#!/bin/bash
APP_NAME="{{ app_name }}"
DATABASE_NAME="{{ database_name }}"
DATABASE_HOST="{{ database_host }}"
DATABASE_USER="{{ database_user }}"
DATABASE_PASSWORD="{{ database_password }}"
DJANGO_SETTINGS_MODULE="{{ django_settings }}.settings"
PYTHON_BASE=$(which python)
USER=$(whoami)
# Paths
BASE="/opt/{{ company_slug }}"
RELEASE_NAME="{{ release_name }}"
RELEASE_DIR="${BASE}/releases/{{ release_name }}"
DJANGO_FOLDER="${RELEASE_DIR}/{{ django_folder }}"
PYTHON_VENV="${RELEASE_DIR}/bin/python"
PYTHON_BIN="/opt/{{ company_slug }}/runtime/pyenv/shims/python"
DUMP_NAME=${BASE}/data/${APP_NAME}/postinstall-${DATABASE_NAME}-sql-$(date +"%Y%m%d%H%M").gz

# Print Format
DEFAULT_POINT_PRINT="..............................................................."
DEFAULT_TRACE_PRINT="--------------------"

echo "User: ${USER}"
echo "${DEFAULT_POINT_PRINT}"
echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 1."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Verificando se o Python existe e se o serviço esta rodando."
echo
if [ ! -f $PYTHON_BASE ]; then
    echo "Python root não encontrado: ${PYTHON_BASE}"
    exit 1
fi

pushd ${RELEASE_DIR}
#. ${RELEASE_DIR}/.env

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 2."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Fazendo backup da base de dados."
echo
if [[ `psql -U postgres -l | grep ${DATABASE_NAME} | wc -l` != '0' ]]
then
    echo 'Cópia de segurança de banco de dados antes de atualizar...'
    mkdir -p ${BASE}/data/${APP_NAME}

    PGUSER="${DATABASE_USER}" PGPASSWORD="${DATABASE_PASSWORD}" pg_dump --no-owner --no-acl -h "${DATABASE_HOST}" \
    "${DATABASE_NAME}" | gzip > ${DUMP_NAME}
    if [ $? -ne 0 ]; then
        echo "Ocorreu algum erro ao tentar fazer o backup dos dados"
        exit 1
    fi
fi

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 3."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Instalando com as seguintes configuraçoes:"
echo "    App Name: ${APP_NAME}"
echo "    Django Settings Module: ${DJANGO_SETTINGS_MODULE}"
echo "    Diretorio da Release: ${RELEASE_DIR}"
echo
echo "Atualizando aplicação."
echo

source ${RELEASE_DIR}/bin/activate
if [ $? -ne 0 ]; then
    echo "Versão Nova, Criando venv no diretorio de release."
    ${PYTHON_BIN} -m venv ${RELEASE_DIR}
    if [ $? -ne 0 ]; then
      echo "VIRTUALENV zoado. $retval"
      exit 1
    fi
    echo "Ativando o venv novamente."
    source ${RELEASE_DIR}/bin/activate
fi

pip install pip -U
pip install -r ${RELEASE_DIR}/requirements.txt
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao instalar as dependencias. $retval"
    exit 1
fi

touch ${BASE}/logs/${APP_NAME}/django-errors.log
export DJANGO_SETTINGS_MODULE=${DJANGO_SETTINGS_MODULE}

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 4."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Rodando as migracoes."
echo
${PYTHON_VENV} ${DJANGO_FOLDER}/manage.py migrate
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao tentar gerar as migrações"
    exit 1
fi


echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 5."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Gerando arquivos estaticos."
echo
${PYTHON_VENV} ${DJANGO_FOLDER}/manage.py collectstatic --no-input

deactivate
popd

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 6."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Altera link para release atual."
echo "${DEFAULT_POINT_PRINT} "
echo
rm -f ${BASE}/${APP_NAME}
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao remover o link da release atual. $retval"
    exit 1
fi

ln -sfnv ${RELEASE_DIR} ${BASE}/${APP_NAME}
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao altera o link da para a nova release. $retval"
    exit 1
fi

rm -rf ${BASE}/conf/${APP_NAME}
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao remover o link da config atual. $retval"
    exit 1
fi

ln -sfnv ${RELEASE_DIR}/conf ${BASE}/conf/${APP_NAME}
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao altera o link da para a nova configuracao. $retval"
#    exit 1
fi

ln -sfnv ${BASE}/logs/${APP_NAME} ${RELEASE_DIR}/logs

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Fim."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Atualização completa."
echo
echo "${DEFAULT_POINT_PRINT}"
echo

echo
echo "--------------------"
echo "Inicie a aplicação:"
echo "--------------------"
echo "> service {{ company_slug }}-${APP_NAME} start"
echo
echo
echo "Comandos comuns para Troubleshooting:"
echo "-------------------------------------"
echo "> tail -100f /opt/{{ company_slug }}/logs/${APP_NAME}/uwsgi.log"
echo
exit 0
