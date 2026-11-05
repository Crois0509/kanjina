# <img width="100%" alt="kanjina banner" src="https://github.com/user-attachments/assets/7658e01c-749b-43d5-82ef-5e7452ab5de9" />

# <img width="30" height="30" alt="icon" src="https://github.com/user-attachments/assets/98ea8e87-d7d9-477b-9c3e-381785c8be17" /> 칸지나 (Kanjina)

> **"JLPT 한자 학습부터 주간 공부량 시각화까지, 가장 쫀득하고 직관적인 일본어 한자 학습 파트너"**

![iOS 18.0+](https://img.shields.io/badge/iOS-18.0%2B-blue?logo=apple)
![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-007ACC?logo=swift)
![CoreData](https://img.shields.io/badge/Data-CoreData-4B0082)

---

## 📌 Executive Summary (프로젝트 요약)

**'칸지나(Kanjina)'** 는 JLPT(N1~N5) 한자 데이터를 50개 단위의 효율적인 모듈식 단위로 학습하고, 오프라인 환경에서도 빠른 검색과 주간 학습 통계를 시각적으로 추적할 수 있도록 개발된 **1인 개발 iOS 애플리케이션**입니다.

- **개발 기간**: 2026.05 (약 4주)
- **팀 구성**: 1인 개인 프로젝트 (기획, UX/UI 디자인, iOS 개발 100%)
- **주요 링크**: 
  - 🎥 [앱 시연 영상 (Notion)](https://alert-okra-cb5.notion.site/Kanjina-40e618d04750805b99cec18211f14e40?source=copy_link)

> 💡 **Showcase Notice**  
> 본 레포지토리는 '칸지나' 서비스의 전체 소스 코드 및 핵심 데이터 모델, 뷰 레이어 구현체를 포함하고 있는 공식 공개 레포지토리입니다.

---

## 📸 UI Preview & Key Features (시연 및 주요 기능)

### 🎬 UI Preview

#### 1) JLPT 학습

| JLPT 급수 선택 | 학습 레벨 선택 | 학습 진행 | 학습 결과 |
|:-:|:-:|:-:|:-:|
| <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 26 02" src="https://github.com/user-attachments/assets/e24ae577-586c-44ba-9ae5-5a103fc712e1" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 26 06" src="https://github.com/user-attachments/assets/679ca0cf-310c-4091-b76f-e11fe09124a1" /> | <img width="983" height="2137" alt="Untitled" src="https://github.com/user-attachments/assets/a249886a-a832-4201-856e-da0b7a2bab78" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 27 33" src="https://github.com/user-attachments/assets/300f6e73-6376-4b29-9074-85980893ab61" /> |

#### 2) 단어장 학습

| 단어장 선택 | 전체 단어장 | 학습한 단어장 | 북마크 단어장 | 암기 모드 |
|:-:|:-:|:-:|:-:|:-:|
| <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 32 39" src="https://github.com/user-attachments/assets/57b4aa91-181d-4885-b65a-fd4cbfb37bdd" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 32 52" src="https://github.com/user-attachments/assets/4252b8cd-9c4d-4ca0-bf7b-78ff573ae145" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 32 59" src="https://github.com/user-attachments/assets/872b0722-5fee-4f31-88cd-0caaea1d526d" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 33 05" src="https://github.com/user-attachments/assets/6f23e9c0-0912-4b9f-85e7-7c7f0f08156f" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 33 14" src="https://github.com/user-attachments/assets/17ef6dde-a97f-4e89-b339-d2b44b28aede" /> |

#### 3) 마이 페이지&설정

| 마이페이지 | 학습 현황 | 설정 항목 |
|:-:|:-:|:-:|
| <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 35 18" src="https://github.com/user-attachments/assets/5f4bed69-ddc9-4d9a-a2f4-7165ce09c032" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 35 23" src="https://github.com/user-attachments/assets/7ccfd9ee-c94b-4211-8298-14cfd0e150e0" /> | <img width="1206" height="2622" alt="Screenshot iPhone 18 Pro 11-04-2026 at 23 35 35" src="https://github.com/user-attachments/assets/de17eefc-19cf-4f16-9147-5670a453b79f" /> |

---

### 📋 주요 기능 매트릭스

| 도메인 | 기능 | 상세 설명 |
| :--- | :--- | :--- |
| **한자 학습** | **JLPT 레벨별 50개 청킹(Chunking)** | N1~N5 난이도별 한자 데이터를 50개씩 모듈화하여 순차적 학습 동기 부여 |
| **한자 검색** | **히라가나 인덱스 바 (Kana Scroll Bar)** | 히라가나/가타카나 행 매핑 및 `scrollTo` 기반 고속 색인 탐색 지원 |
| **통계 & 리포트** | **주간 학습량 시각화 (Swift Charts)** | `.chartXSelection` 인터랙션을 적용하여 일자별 학습 시간 및 정답률 추적 |
| **데이터 관리** | **오프라인 퍼시스턴스 (Core Data)** | 서버 통신 없는 로컬 오프라인 환경에서 북마크 및 학습 이력을 안전하게 영속화 |

---

## 🛠 Tech Stack & Architecture (기술 스택 및 아키텍처)

### 💻 Technology Stack

| 카테고리 | 기술 스택 | 선택 이유 (Why) |
| :--- | :--- | :--- |
| **Language & UI** | `Swift 5`, `SwiftUI` | 선언형 UI 프레임워크를 채택하여 상태 중심의 뷰 렌더링을 단순화하고 개발 생산성 향상 |
| **Architecture** | `MVVM`, `Coordinator Pattern` | View와 학습 비즈니스 로직을 분리하고, Core Data와 JSON 로더 레이어 추상화 |
| **Persistence** | `Core Data`, `Codable JSON` | 번들 내 2,500+ JLPT 한자 데이터를 빠르게 파싱하고 사용자 학습 로그는 로컬에 영속 저장 |
| **Data Visualization**| `Swift Charts` | 외부 라이브러리 없이 네이티브 성능으로 인터랙티브 막대그래프 렌더링 |
| **Tools** | `Xcode 16`, `Git/GitHub`, `Instruments` | 메모리 및 제스처 레이아웃 성능 추적, 버전 관리 |

---

### 📐 Architecture & Data Flow

#### 1) Data Status Flow

단일 진실 공급원(Single Source of Truth)을 지향하며, Local JSON 파싱 데이터와 CoreData 영역을 분리하여 데이터 무결성을 보장합니다.
또한 CleanArchitecture처럼 단방향 의존성을 의도했으며, 필요시 의존성 역전 원칙을 통해 상위 레이어에 작업을 전달하는 방식을 사용했습니다.

<img width="864" height="259" alt="Group 1" src="https://github.com/user-attachments/assets/58b3b59f-ddf6-4ab8-9f1b-129da21e6264" />

#### 2) Navigation Flow

Coordinator Pattern을 활용하여 일관성 있는 화면 흐름을 구현하고,
각 탭별로 화면 이동에 대한 의존성을 분리하여 간섭을 최소화 했습니다.

<img width="5184" height="1440" alt="Untitled" src="https://github.com/user-attachments/assets/e5eccf09-f2a7-41fe-88b4-31c560094624" />

---

## ⭐️ Technical Challenges & Troubleshooting (핵심 기술적 도전 과제)

### 1️⃣ Core Data XML 데이터 타입 불일치 및 Modeler 백지 화면 복구

#### 🚨 Problem
Xcode에서 `.xcdatamodeld` 파일 편집기 창을 열었을 때 엔티티 편집기가 렌더링되지 않고 **백지 화면(White Screen)** 으로 표시되는 현상 발생. 
앱 컴파일은 정상 작동하여 원인 파악이 어려웠음.

#### 🔥 Action
`.xcdatamodeld` 패키지 내부의 `contents` XML 코드를 직접 추적 분석. `KanjiEntity`의 `bookmark` 속성 타입이 `Boolean`으로 설정되어 있음에도 기본값 문자열이 소수점 형태(`defaultValueString="0.0"`)로 잘못 기입되어 Xcode UI 렌더러가 파싱 크래시를 일으킨 것과 `usedWithSwiftData="YES"` 옵션 충돌을 규명함.

```xml
// ❌ 수정 전: Boolean 타입에 소수점 문자열 0.0 배정 및 SwiftData 옵션 충돌
<model ... usedWithSwiftData="YES">
    <attribute name="bookmark" optional="YES" attributeType="Boolean" defaultValueString="0.0" usesScalarValueType="YES"/>

// ✅ 수정 후: Boolean 타입에 맞는 NO 배정 및 순수 Core Data 선언
<model ... usedWithSwiftData="NO">
    <attribute name="bookmark" optional="YES" attributeType="Boolean" defaultValueString="NO" usesScalarValueType="YES"/>
```

또한, `~/Library/Developer/Xcode/DerivedData` 및 프로젝트 패키지 내 `xcuserdata` 폴더를 삭제하여 Xcode가 붙잡고 있던 손상된 작업 공간 레이아웃 캐시를 강제 초기화함.

#### 🏆 Result
데이터 모델 손실 없이 편집기 UI를 정상 복구하였으며, 엔티티 속성 기본값 설정 및 XML 구성 시 타입 안전성 검증 기준을 정립함.

---

### 2️⃣ Coordinator와 뷰 재사용 문제 해결

#### 🚨 Problem
`LearningCoordinator`와 `VocabularyNoteCoordinator`의 2개의 Coordinator에서 동일한 `LearningView`를 사용해야 하는 상황인데,
`LearningView`는 `CompleteView`로 Push가 가능해야 하는 문제가 있음.

`LearningView`는 `@EnviromentObject`를 사용하여 외부에서 Coordinator를 주입받고 있었는데,
2개의 Coordinator는 서로 `Route`가 다르기 때문에 2개의 Coordinator를 모두 주입받아도 Push 로직을 그대로 사용할 수 없는 문제가 발생.

#### 🔥 Action
이를 해결하기 위해 기존에 외부에서 주입받던 `@EnviromentObject`를 제거하고,
`onPushToView: () -> Void`라는 클로저 변수를 추가.

```swift
// LearningView
var onPushToView: () -> Void
```

Coordinator에서 `LearningView`를 초기화할 때 이 클로저를 통해 push 위치를 설정하고,
`LearningView`에서 `CompleteView`로 Push 되어야 하는 시점에 클로저를 실행하도록 로직 수정

```swift
// Coordinator bulid Method
func build(_ view: LearningRoute) {
  switch view {
  case .learning:
    LearningView(onPushToView: { [weak self] in
      self?.push(.complete)
    })
  }
}
```

#### 🏆 Result
이를 통해 2개의 Coordinator에서 동일한 로직으로 `LearningView`로 화면 이동을 구현하고,
`CompleteView`로 Push하는 기능까지 완전히 동일한 로직으로 구현하여 코드 일관성을 높이고 문제를 해결함.

---

### 3️⃣ CoreData 저장 로직 최적화

#### 🚨 Problem
JLPT 일본어 급수별 학습을 진행할 때, 학습 결과를 `CoreData`에 저장하는 로직이 있는데
한 문제를 풀 때마다 저장 로직을 실행하게 되면 `CoreData`에 과부하가 걸리게 되고, UX를 해칠 가능성이 있음. (딜레이, UI 버벅임 등)

#### 🔥 Action
이에 대한 해결방안을 고민하다가, 문제별로 학습 결과를 저장하는 객체 `KanjiLearningResult`를 만들고, ViewModel의 State에 `[KanjiLearningResult]` 배열을 추가하여 현재 학습상태를 저장하도록 구현.
그리고 모든 문제(50문제)를 모두 풀었을 때 해당 배열을 사용하여 `CoreData`에 저장하는 로직을 1회만 실행하도록 구현.

<img width="1132" height="282" alt="Group 2" src="https://github.com/user-attachments/assets/bc812ca1-528a-4e45-a4f5-e321180ab321" />

#### 🏆 Result
결과적으로 문제를 푸는 동안의 딜레이나 UI 버벅임이 없어 UX를 최적화 하고,
저장 로직을 1회만 실행하도록 하여 `CoreData`에 가해지는 부담도 최소화함.
또, `[KanjiLearningResult]` 배열을 활용하면 추후 학습 진행 상태에 대한 백업 기능도 구현이 가능하여 기능 확장성까지 향상시킴.

---

## 📁 Directory Structure (디렉토리 구조)

```text
kanjina/
├── App
│   ├── Info.plist
│   ├── kanjinaApp.swift
│   └── PrivacyInfo.xcprivacy
├── Config
│   ├── CoreDataConfig.swift
│   └── UserDefaultsConfig.swift
├── Coordinator
│   ├── App
│   │   ├── AppCoordinator.swift
│   │   └── AppCoordinatorView.swift
│   ├── Coordinator.swift
│   ├── Learning
│   │   ├── LearningCoordinator.swift
│   │   └── LearningCoordinatorView.swift
│   ├── Main
│   │   ├── MainCoordinator.swift
│   │   └── MainCoordinatorView.swift
│   ├── MyPage
│   │   ├── MyPageCoordinator.swift
│   │   └── MyPageCoordinatorView.swift
│   └── VocabularyNote
│       ├── VocabularyNoteCoordinator.swift
│       └── VocabularyNoteCoordinatorView.swift
├── Extension
│   ├── Array+ext.swift
│   ├── Date+ext.swift
│   ├── Font+ext.swift
│   ├── Int+ext.swift
│   ├── UIFont+ext.swift
│   └── View+ext.swift
├── Managers
│   ├── CoreData
│   │   ├── CoreDataManager.swift
│   │   ├── DailyStudy.swift
│   │   ├── KanjiContainer.xcdatamodeld
│   │   │   └── KanjiContainer.xcdatamodel
│   │   │       └── contents
│   │   └── KanjiLearningResult.swift
│   ├── DIContainer
│   │   └── DIContainer.swift
│   ├── KanjiManager
│   │   ├── Kanji.swift
│   │   ├── KanjiDataManager.swift
│   │   └── KanjiError.swift
│   └── LocalStorage
│       └── LocalStorage.swift
├── Presentation
│   ├── Common
│   │   ├── ActiveButtonStyle.swift
│   │   ├── CommonCapsuleView.swift
│   │   ├── CommonScrollIndicatorView.swift
│   │   ├── CommonSearchView.swift
│   │   ├── CommonSectionView.swift
│   │   ├── CommonSegmentedControl.swift
│   │   ├── CommonToolbar.swift
│   │   ├── LearningProgressView.swift
│   │   ├── ListCell.swift
│   │   ├── SheetState.swift
│   │   ├── SmoothAnimationButtonStyle.swift
│   │   ├── ToastView.swift
│   │   └── ToolBarState.swift
│   ├── Learning
│   │   ├── CompleteView.swift
│   │   ├── LearningSelectView.swift
│   │   ├── LearningView.swift
│   │   └── PickerAlertView.swift
│   ├── Main
│   │   └── MainView.swift
│   ├── MyPage
│   │   ├── LearningSituationDetailView.swift
│   │   ├── LearningSituationView.swift
│   │   ├── LegendView.swift
│   │   ├── MyPageSection.swift
│   │   └── MyPageView.swift
│   ├── Onboarding
│   │   └── OnboardingView.swift
│   └── VocabularyNote
│       ├── AllVocaList.swift
│       ├── BookmarkVocaView.swift
│       ├── KanjiDetailView.swift
│       ├── LearnedVocaView.swift
│       ├── MemorizationButton.swift
│       └── VocabularyNoteView.swift
├── Resource
│   ├── Assets.xcassets
│   ├── Data
│   │   ├── jlpt_N1.json
│   │   ├── jlpt_N2.json
│   │   ├── jlpt_N3.json
│   │   ├── jlpt_N4.json
│   │   └── jlpt_N5.json
│   └── Font
│       └── ShoraiSansStdNVar.ttf
└── ViewModel
    ├── AppViewModel.swift
    └── KanjiViewModel.swift
```

---

## 🚀 Getting Started & Build Guide (빌드 및 실행 가이드)

### Prerequisites (선행 조건)

- **macOS**: Sonoma 14.0 이상
- **Xcode**: 16.0 이상
- **iOS Target**: iOS 18.0 이상

### Build Steps (실행 방법)

1. **Repository Clone**
   ```bash
   git clone https://github.com/Crois0509/kanjina.git
   cd kanjina
   ```

2. **Xcode 프로젝트 열기**
   ```bash
   open kanjina.xcodeproj
   ```

3. **Target 기기 선택 후 빌드**
   - iOS Simulator 또는 연결된 실기기 선택
   - 단축키 `Cmd + R`을 누르고 빌드 및 실행을 진행합니다.
