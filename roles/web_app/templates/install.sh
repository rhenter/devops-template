#!/bin/bash
APP_NAME="{{ app_name }}"
PYTHON_BASE=$(which python3.6)
USER=$(whoami)
# Paths
BASE="/opt/{{ company_slug }}"
RELEASE_DIR="${BASE}/releases/{{ release_name }}"
PYTHON_VENV="${RELEASE_DIR}/bin/python"

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

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 2."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Instalando com as seguintes configuraçoes:"
echo "    App Name: ${APP_NAME}"
echo "    Diretorio da Release: ${RELEASE_DIR}"
echo
echo "Atualizando aplicação."
echo

source ${RELEASE_DIR}/bin/activate
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao tentar ativar o virtualenv. $retval"
    echo "Criando venv no diretorio de release."
    ${PYTHON_BASE} -m venv ${RELEASE_DIR}
    echo "Ativando o venv novamente."
    source ${RELEASE_DIR}/bin/activate
fi

pip install pip -U
pip install -r ${RELEASE_DIR}/requirements.txt
if [ $? -ne 0 ]; then
    echo "Ocorreu algum erro ao instalar as dependencias. $retval"
    exit 1
fi

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Passo 3."
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

ln -sfnv ${BASE}/logs/${APP_NAME} ${RELEASE_DIR}/logs
chown -R {{ company_slug }} ${RELEASE_DIR}
chown -R {{ company_slug }} ${RELEASE_DIR}/logs

echo
echo "${DEFAULT_TRACE_PRINT}"
echo "Fim."
echo "${DEFAULT_TRACE_PRINT}"
echo
echo "Atualizacao completa."
echo
echo "${DEFAULT_POINT_PRINT}"
echo

echo
echo "--------------------"
echo "Inicie a aplicação:"
echo "--------------------"
echo "> service ${APP_NAME} start"
echo
echo
echo "Comandos comuns para Troubleshooting:"
echo "-------------------------------------"
echo "> tail -100f /opt/{{ company_slug }}/logs/${APP_NAME}/*"
echo
exit 0
