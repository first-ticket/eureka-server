# eureka-server

First Ticket 프로젝트의 Service Discovery 서버.  
모든 마이크로서비스의 인스턴스 정보를 등록·관리하며, API Gateway 및 각 서비스의 동적 라우팅 기반을 제공한다.

---

## 📌 핵심 기능

각 마이크로서비스가 기동 시 Eureka 에 인스턴스를 등록하고, 서비스 간 호출 시 로드밸런서가 Eureka 에서 인스턴스 목록을 조회한다.

```
마이크로서비스 기동 → Eureka 등록 (IP:Port)
                          ↓
API Gateway lb://service-name → Eureka 조회 → 인스턴스 선택 → 라우팅
```

ECS Fargate 환경에서 컨테이너 IP 가 동적으로 할당되므로, 전 서비스에 `prefer-ip-address: true` 설정이 적용되어 있다.

---

## 🛠 기술 스택

| 항목 | 기술 |
| --- | --- |
| 서비스 디스커버리 | Spring Cloud Netflix Eureka Server |
| 인스턴스 캐시 | Caffeine (W-TinyLFU, 기본 Guava 대비 캐시 히트율 향상) |

공통 기술 스택은 [공통 README](https://github.com/first-ticket/.github/blob/main/profile/README.md) 참고.

---

## 📁 패키지 구조

```text
com.firstticket.eurekaserver
└── EurekaserverApplication.java    # @EnableEurekaServer
```

---

## 🌐 포트

| 환경  | 포트                 |
| ----- | -------------------- |
| local | 8761                 |
| prod  | 8761 (컨테이너 내부) |

대시보드: `http://localhost:8761`

---

## 🚀 로컬 실행

### 사전 조건

별도 인프라 의존성 없음. 단독 기동 가능.

### 실행

```bash
./gradlew bootRun
```

또는 IntelliJ 에서 `EurekaserverApplication` 실행.

---

## 🔗 클라이언트 서비스 연동

### 의존성 (`build.gradle`)

```gradle
implementation 'org.springframework.cloud:spring-cloud-starter-netflix-eureka-client'
```

### 설정 (`application.yml`)

```yaml
spring:
  application:
    name: {서비스명}  # Eureka 대시보드 식별자 - 아키텍처 문서 서비스명과 일치

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
    tls:
      enabled: false
  instance:
    prefer-ip-address: true  # ECS Fargate 동적 IP 환경 필수
```

### ECS 배포 환경변수

| 환경변수                                    | 값                                                |
| ------------------------------------------- | ------------------------------------------------- |
| `EUREKA_CLIENT_SERVICEURL_DEFAULTZONE`      | `http://{EUREKA_SERVER_INTERNAL_IP}:8761/eureka/` |
| `MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE` | `health,info,prometheus`                          |

---

## 📋 전체 스택 기동 순서

```
1. Eureka Server   (본 서비스)
2. Config Server
3. API Gateway
4. 각 마이크로서비스
```

---

## 🔍 헬스체크

```bash
curl http://localhost:8761/actuator/health
# → {"status":"UP"}
