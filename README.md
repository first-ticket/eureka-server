# eureka-server

First Ticket MSA 프로젝트의 Service Discovery 서버입니다.
모든 마이크로서비스의 인스턴스 정보를 등록·관리하며, API Gateway 및 각 서비스의 동적 라우팅 기반을 제공합니다.

## 기술 스택

- Java 21
- Spring Boot 3.5.13
- Spring Cloud 2025.0.1 (Netflix Eureka Server)

---

## 로컬 실행 가이드

### 사전 요구사항
- JDK 21
- Docker Desktop

### 방법 1 — Docker로 실행 (권장)

```bash
# 1. 빌드
./gradlew build

# 2. 컨테이너 실행
docker-compose up --build
```

### 방법 2 — IntelliJ에서 직접 실행

`EurekaserverApplication.java` 실행

### 실행 확인

`http://localhost:8761` 접속 → Eureka 대시보드 확인

---

## 다른 서비스 연동 방법
> spring cloud config server 구축 후 변경될 수 있습니다

### 1. 각 마이크로서비스 의존성 추가 (`build.gradle`)

```gradle
ext {
    set('springCloudVersion', "2025.0.1")
}

dependencies {
    implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
}

dependencyManagement {
    imports {
        mavenBom "org.springframework.cloud:spring-cloud-dependencies:${springCloudVersion}"
    }
}
```

### 2. 설정 추가 (`application.yml`)

```yaml
spring:
  application:
    name: {서비스명}  # 예: user-service

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```

> `spring.application.name`이 Eureka 대시보드에 표시되는 서비스 식별자입니다.
> 아키텍처 문서의 서비스명과 일치시켜 주세요.

---

## AWS 배포 환경설정 (ECS Fargate)
> 추후 배포 진행시 협의 후 조정될 수 있습니다.

### 필수 환경변수

| 환경변수 | 설명 | 예시 |
|---|---|---|
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | Actuator 노출 엔드포인트 | `health,info,prometheus` |

### ECS 헬스체크 설정

```
경로:     /actuator/health
포트:     8761
프로토콜: HTTP
```

### 클라이언트 서비스 ECS 환경변수

각 서비스 ECS Task에 아래 환경변수를 추가합니다.

| 환경변수 | 값 |
|---|---|
| `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE` | `http://{EUREKA_SERVER_INTERNAL_IP}:8761/eureka/` |

> ECS Fargate는 컨테이너 IP가 동적으로 할당됩니다.
> `prefer-ip-address: true` 설정이 적용되어 있으므로 별도 hostname 설정은 불필요합니다.

---

## 기동 순서

MSA 전체 스택 실행 시 아래 순서를 반드시 지켜주세요.

```
1. Eureka Server
2. Config Server
3. API Gateway
4. 각 마이크로서비스
```