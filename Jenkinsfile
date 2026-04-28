pipeline {
    agent any
    
    environment {
        AWS_REGION = "ap-south-1"
        ACCOUNT_ID = "972379852061"
        ECR_REPO = "animated-web"
        IMAGE_TAG = "${BUILD_NUMBER}"
        CLUSTER_NAME = "prod-cluster"
    }
    
    stages {
        stage ('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage ('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Gauthamdevops/jenkins-eks-cicd.git'
            }
        }
        
        stage ('Build Docker Image') {
            steps {
                sh 'docker build -t $ECR_REPO:$IMAGE_TAG .'
            }
        }

        stage('Push to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin \
                    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

                    docker tag $ECR_REPO:$IMAGE_TAG \
                    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

                    docker push \
                    $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                    aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION
                    
                    #kubectl apply -f deployment.yml

                    kubectl set image deployment/animated-web-deploy animated-web=$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO:$IMAGE_TAG

                    kubectl rollout status deployment/animated-web-deploy
                    '''
                }
            }
        }
       
        stage('Update Deployment File') {
            steps {
                sh '''
                sed -i "s|image:.*|image: $ECR_REPO:$IMAGE_TAG|" k8s/deployment.yml
                '''
           }
        }
    }
    
    post {
        success {
            echo "Deployment Successful 🚀"
        }
        failure {
            echo "Deployment Failed ❌"
        }
    }
}
