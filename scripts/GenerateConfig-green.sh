CLUSTER_NAME="gke_gamescenter-286810_asia-east1-a_gitlab-runner-cluster"
APPLICANT="opger"
APPLICANT_NS="default"
PROJECT="gitlab-runner"
TEAM="rd"
API_SERVER="https://35.194.178.24"
ADMIN_KUBE_CONFIG="/Users/jiasiang/.kube/gitlab-runner-cluster-config"

kubectl create ns $APPLICANT_NS --kubeconfig $ADMIN_KUBE_CONFIG

mkdir output-${APPLICANT}-${CLUSTER_NAME}

cat <<EOF > output-${APPLICANT}-${CLUSTER_NAME}/serviceaccount.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${APPLICANT}-${TEAM}
  namespace: $APPLICANT_NS
EOF

kubectl apply -f output-${APPLICANT}-${CLUSTER_NAME}/serviceaccount.yaml --kubeconfig $ADMIN_KUBE_CONFIG

SECRET=$(kubectl get secret -n $APPLICANT_NS --kubeconfig $ADMIN_KUBE_CONFIG | grep ${APPLICANT}-${TEAM}-token | awk '{print $1}')
#SECRET=$(kubectl get sa --kubeconfig $ADMIN_KUBE_CONFIG -n $APPLICANT_NS admin -o go-template='{{range .secrets}}{{.name}}{{end}}')

echo "--------secret-------"
echo $SECRET

CA_CERT=$(kubectl -n $APPLICANT_NS --kubeconfig $ADMIN_KUBE_CONFIG get secret ${SECRET} -o yaml | awk '/ca.crt:/{print $2}'| head -n 1)
echo "--------ca_cert-------"
echo $CA_CERT

TOKEN=$(kubectl -n $APPLICANT_NS --kubeconfig $ADMIN_KUBE_CONFIG get secret ${SECRET} -o go-template='{{.data.token}}'| base64 --decode)
echo "-------token-----------"
echo $TOKEN

cat <<EOF > output-${APPLICANT}-${CLUSTER_NAME}/${APPLICANT}-${CLUSTER_NAME}.conf
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_CERT
    server: $API_SERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    user: $APPLICANT
  name: ${CLUSTER_NAME}
current-context: ${CLUSTER_NAME}
preferences: {}
users:
- name: $APPLICANT
  user:
    token: $TOKEN
EOF

cat <<EOF > output-${APPLICANT}-${CLUSTER_NAME}/clusterrole.yaml
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${APPLICANT}-${TEAM}-${PROJECT}-clusterrole
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: 'true'
rules:
- apiGroups:
  - ""
  resources:
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  - secrets
  - services/proxy
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - serviceaccounts
  verbs:
  - impersonate
- apiGroups:
  - ""
  resources:
  - pods
  - pods/attach
  - pods/exec
  - pods/portforward
  - pods/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - persistentvolumeclaims
  - replicationcontrollers
  - replicationcontrollers/scale
  - secrets
  - serviceaccounts
  - services
  - services/proxy
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - apps
  resources:
  - daemonsets
  - deployments
  - deployments/rollback
  - deployments/scale
  - replicasets
  - replicasets/scale
  - statefulsets
  - statefulsets/scale
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - batch
  resources:
  - cronjobs
  - jobs
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - deployments
  - deployments/rollback
  - deployments/scale
  - ingresses
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicationcontrollers/scale
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - networkpolicies
  verbs:
  - create
  - delete
  - deletecollection
  - patch
  - update
- apiGroups:
  - ""
  resources:
  - configmaps
  - endpoints
  - persistentvolumeclaims
  - persistentvolumeclaims/status
  - pods
  - replicationcontrollers
  - replicationcontrollers/scale
  - serviceaccounts
  - services
  - services/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - bindings
  - events
  - limitranges
  - namespaces/status
  - pods/log
  - pods/status
  - replicationcontrollers/status
  - resourcequotas
  - resourcequotas/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - ""
  resources:
  - namespaces
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources:
  - controllerrevisions
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - replicasets
  - replicasets/scale
  - replicasets/status
  - statefulsets
  - statefulsets/scale
  - statefulsets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - autoscaling
  resources:
  - horizontalpodautoscalers
  - horizontalpodautoscalers/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - batch
  resources:
  - cronjobs
  - cronjobs/status
  - jobs
  - jobs/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources:
  - daemonsets
  - daemonsets/status
  - deployments
  - deployments/scale
  - deployments/status
  - ingresses
  - ingresses/status
  - networkpolicies
  - replicasets
  - replicasets/scale
  - replicasets/status
  - replicationcontrollers/scale
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - policy
  resources:
  - poddisruptionbudgets
  - poddisruptionbudgets/status
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - networking.k8s.io
  resources:
  - ingresses
  - ingresses/status
  - networkpolicies
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - authorization.k8s.io
  resources:
  - localsubjectaccessreviews
  verbs:
  - create
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - rolebindings
  - roles
  verbs:
  - create
  - delete
  - deletecollection
  - get
  - list
  - patch
  - update
  - watch

EOF

kubectl apply -f output-${APPLICANT}-${CLUSTER_NAME}/clusterrole.yaml --kubeconfig $ADMIN_KUBE_CONFIG

cat <<EOF > output-${APPLICANT}-${CLUSTER_NAME}/clusterrolebinding.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: ${APPLICANT}-${TEAM}-${PROJECT}-clusterrole-binding
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: 'true'
subjects:
  - kind: ServiceAccount
    name: ${APPLICANT}-${TEAM}
    namespace: ${APPLICANT_NS}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
#  name: ${APPLICANT}-${TEAM}-${PROJECT}-clusterrole
EOF

kubectl apply -f output-${APPLICANT}-${CLUSTER_NAME}/clusterrolebinding.yaml --kubeconfig $ADMIN_KUBE_CONFIG
