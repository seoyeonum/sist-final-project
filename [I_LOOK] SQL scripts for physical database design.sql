SELECT USER
FROM DUAL;
--==>> SCOTT

-- DB 물리 설계를 위한 sql 구문 작성

-- 내가 작성해야 하는 테이블
/*
    관리자
    공지사항 유형
    공지사항 등록
    일반 돌봄 예약 신청
    일반 돌봄 예약 확정
    취소 사유 분류
    일반 돌봄 예약 확정 후 취소(시터가 취소)
    일반 돌봄 예약 확정 후 취소 환불(시터)
    일반 돌봄 예약 확정 후 취소(부모가 취소)
    일반 돌봄 예약 확정 후 취소 환불(부모)
    일반 돌봄 리뷰
    일반 돌봄 객관식 응답
    돌봄 객관식 응답 종류
*/

---------------------------------------------
-- 제약 조건 삭제 구문
ALTER TABLE NOTICE_TYPE
DROP CONSTRAINT NOTICE_NOTICE_TYPE_ID_PK;

-- 제약 조건 조회 구문
SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE, TABLE_NAME
FROM USER_CONSTRAINTS
WHERE TABLE_NAME = 'NOTICE_TYPE';
---------------------------------------------

-- 테이블 삭제 구문
DROP TABLE ADMIN_REG;
DROP TABLE NOTICE_TYPE;
DROP TABLE NOTICES;
DROP TABLE GEN_REQ;
DROP TABLE GEN_CONFIRMED;
DROP TABLE REASONS_CANCELED;
DROP TABLE GEN_PAR_CONFIRMED_CANCELED;
DROP TABLE GEN_PAR_CONFIRMED_REFUNDED;
DROP TABLE GEN_SIT_CONFIRMED_CANCELED;
DROP TABLE GEN_REVIEWS;
DROP TABLE GEN_MULTIPLE_REVIEWS;
DROP TABLE GEN_MULTIPLE_TYPES;

-- 테이블 조회 구문
DESC ADMIN_REG;
DESC NOTICE_TYPE;
DESC NOTICES;
DESC GEN_REQ;
DESC GEN_CONFIRMED;
DESC REASONS_CANCELED;
DESC GEN_PAR_CONFIRMED_CANCELED;
DESC GEN_PAR_CONFIRMED_REFUNDED;
DESC GEN_SIT_CONFIRMED_CANCELED;
DESC GEN_SIT_CONFIRMED_REFUNDED;
DESC GEN_REVIEWS;
DESC GEN_MULTIPLE_REVIEWS;
DESC GEN_MULTIPLE_TYPES;
---------------------------------------------
----------------------------------------------------------------------------------

--● 테이블 생성 및 제약조건 구문 작성

--○ 관리자(ADMIN_REG)
-- 테이블 생성
CREATE TABLE ADMIN_REG
( ADMIN_REG_ID      VARCHAR2(20)
, ID                VARCHAR2(20)    NOT NULL
, PW                VARCHAR2(30)    NOT NULL
);
--==>> Table ADMIN_REG이(가) 생성되었습니다.

-- 제약조건 부여
ALTER TABLE ADMIN_REG
ADD ( CONSTRAINT ADMIN_REG_ID_PK PRIMARY KEY(ADMIN_REG_ID) );
--==>> Table ADMIN_REG이(가) 변경되었습니다.

ALTER TABLE ADMIN_REG
ADD ( CONSTRAINT ADMIN_REG_ID_UK UNIQUE(ID) );
--==>> Table ADMIN_REG이(가) 변경되었습니다.



--○ 공지사항 유형
-- 테이블 생성
CREATE TABLE NOTICE_TYPE
( NOTICE_TYPE_ID    CHAR(3)
, TYPE              VARCHAR2(50)    NOT NULL
);
--==>> Table NOTICE_TYPE이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE NOTICE_TYPE
ADD ( CONSTRAINT NOTICE_TYPE_ID_PK PRIMARY KEY(NOTICE_TYPE_ID) );
--==>> Table NOTICE_TYPE이(가) 변경되었습니다.



--○ 공지사항 등록
-- 테이블 생성
CREATE TABLE NOTICES
( NOTICE_ID         VARCHAR2(20)
, NOTICE_TYPE_ID    CHAR(3)         NOT NULL
, SUBJECT           VARCHAR2(50)    NOT NULL
, CONTENT           VARCHAR2(3000)  NOT NULL          -- 내용: 1500자까지 등록 가능
, HITCOUNT          NUMBER    DEFAULT 0     NOT NULL
, NOTICED_DATE      DATE      DEFAULT SYSDATE       NOT NULL
);
--==>> Table NOTICES이(가) 생성되었습니다

-- 제약조건 부여
ALTER TABLE NOTICES
ADD ( CONSTRAINT NOTICE_ID_PK PRIMARY KEY(NOTICE_ID) );
--==>> Table NOTICES이(가) 변경되었습니다.

ALTER TABLE NOTICES
ADD ( CONSTRAINT NOTICE_TYPE_ID_FK FOREIGN KEY(NOTICE_TYPE_ID)
                 REFERENCES NOTICE_TYPE(NOTICE_TYPE_ID) );
--==>> Table NOTICES이(가) 변경되었습니다.



--○ 일반 돌봄 예약 신청
-- 테이블 생성
CREATE TABLE GEN_REQ
( GEN_REQ_ID	    VARCHAR2(20)
, GEN_REG_ID	    VARCHAR2(20)		NOT NULL
, PAR_BACKUP_ID	    VARCHAR2(20)		NOT NULL
, MESSAGE	        VARCHAR2(500)		NULL
, START_DATE	    DATE	        	NOT NULL
, END_DATE	        DATE		        NOT NULL
, START_TIME	    DATE		        NOT NULL
, END_TIME	        DATE		        NOT NULL
, REQ_DATE	        DATE	DEFAULT SYSDATE	NOT NULL
, SIT_READ_DATE 	DATE		        NULL
);
--==>> Table GEN_REQ이(가) 생성되었습니다.


-- 제약조건 부여
ALTER TABLE GEN_REQ
ADD ( CONSTRAINT GEN_REQ_ID_PK PRIMARY KEY(GEN_REQ_ID) );
--==>> Table GEN_REQ이(가) 변경되었습니다.

ALTER TABLE GEN_REQ
ADD ( CONSTRAINT GEN_REQ_GEN_REG_ID_FK FOREIGN KEY(GEN_REG_ID)
                 REFERENCES PAR_BACKUP(GEN_REG_ID)
    , CONSTRAINT GEN_REQ_PAR_BACKUP_ID_FK FOREIGN KEY(PAR_BACKUP_ID)
                 REFERENCES GEN_R
    , CONSTRAINT GEN_REQ_START_DATE_CK CHECK(START_DATE <= END_DATE)
    --, CONSTRAINT GEN_REQ_END_DATE_CK CHECK(START_DATE <= END_DATE)              -- "GEN_REQ_START_DATE_CK"와 중복. 삭제.
    --, CONSTRAINT GEN_REQ_START_TIME_CK CHECK(START_TIME <= END_TIME)
    --, CONSTRAINT GEN_REQ_END_TIME_CK CHECK(START_TIME <= END_TIME)              -- "GEN_REQ_START_TIME_CK"와 중복. 삭제.
    , CONSTRAINT GEN_REQ_SIT_READ_DATE CHECK(SIT_READ_DATE >= REQ_DATE)
);

-- 시작일과 종료일 간의 간격을 넣어야 하는가? 30일 차이? → 여기서 설정 하는 게 아닌듯!
-- 시작시와 종료시 간의 제약을 넣어야 하는가? 8시~19시 범위? → 여기서 설정 하는 게 아닌듯!



--○ 일반 돌봄 예약 확정
-- 테이블 생성
CREATE TABLE GEN_CONFIRMED
( GEN_CONFIRMED_ID	VARCHAR2(20)
, GEN_REQ_ID	    VARCHAR2(20)		NOT NULL
, CONFIRMED_DATE 	DATE        DEFAULT SYSDATE	    NOT NULL
, PAR_READ_DATE 	DATE	        	NULL
);
--==>> Table GEN_CONFIRMED이(가) 생성되었습니다.

-- 제약조건 부여
ALTER TABLE GEN_CONFIRMED
ADD ( CONSTRAINT GEN_CONFIRMED_ID_PK PRIMARY KEY(GEN_CONFIRMED_ID) );
--==>> Table GEN_CONFIRMED이(가) 변경되었습니다.

ALTER TABLE GEN_CONFIRMED
ADD ( CONSTRAINT GEN_CONFIRMED_GEN_REQ_ID_FK FOREIGN KEY(GEN_REQ_ID)
                 REFERENCES GEN_REQ(GEN_REQ_ID)
    , CONSTRAINT GEN_CONFIRMED_PAR_READ_DATE_CK CHECK(PAR_READ_DATE <= CONFIRMED_DATE) );
--==>> Table GEN_CONFIRMED이(가) 변경되었습니다.



--○ 취소 사유 분류
-- 테이블 생성
CREATE TABLE REASONS_CANCELED
( REASON_CANCELED_ID       CHAR(3)
, TYPE                     VARCHAR2(200)    NOT NULL
);
--==>> Table REASONS_CANCELED이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE REASONS_CANCELED
ADD ( CONSTRAINT REASONS_CANCELED_ID_PK PRIMARY KEY(REASON_CANCELED_ID) );
--==>> Table REASONS_CANCELED이(가) 변경되었습니다.



--○ 일반 돌봄 예약 확정 후 취소(부모가 취소)
-- 테이블 생성
CREATE TABLE GEN_PAR_CONFIRMED_CANCELED
( GEN_PAR_CONFIRMED_CANCELED_ID	    VARCHAR2(20)
, REASON_CANCELED_ID	    CHAR(3)		    NOT NULL
, GEN_CONFIRMED_ID	        VARCHAR2(20)	NOT NULL
, CANCELED_DATE	            DATE	        DEFAULT SYSDATE	NOT NULL
, PAR_READ_DATE	            DATE		    NULL
, SIT_READ_DATE         	DATE		    NULL
);
--==>> Table GEN_PAR_CONFIRMED_CANCELED이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE GEN_PAR_CONFIRMED_CANCELED
ADD ( CONSTRAINT GEN_PAR_CON_CANCELED_ID_PK PRIMARY KEY(GEN_PAR_CONFIRMED_CANCELED_ID) );
--==>> Table GEN_PAR_CONFIRMED_CANCELED이(가) 변경되었습니다.

ALTER TABLE GEN_PAR_CONFIRMED_CANCELED
ADD ( CONSTRAINT G_P_C_C_REASON_CANCELED_ID_FK FOREIGN KEY(REASON_CANCELED_ID)
                 REFERENCES REASON_CANCELED(REASON_CANCELED_ID)
    , CONSTRAINT G_P_C_C_GEN_CONFIRMED_ID_FK FOREIGN KEY(GEN_CONFIRMED_ID)
                 REFERENCES GEN_CONFIRMED(GEN_CONFIRMED_ID)
    , CONSTRAINT G_P_C_C_PAR_READ_DATE_CK CHECK(PAR_READ_DATE >= CANCELED_DATE)
    , CONSTRAINT G_P_C_C_SIT_READ_DATE_CK CHECK(SIT_READ_DATE >= CANCELED_DATE) );



--○ 일반 돌봄 예약 확정 후 취소 환불(부모)
-- 테이블 생성
CREATE TABLE GEN_PAR_CONFIRMED_REFUNDED
( GEN_PAR_CONFIRMED_REFUNDED_ID	    VARCHAR2(20)
, GEN_PAR_CONFIRMED_CANCELED_ID	    VARCHAR2(20)		NOT NULL
, AMOUNT	       NUMBER	    	NOT NULL
, REFUNDED_DATE	   DATE	            DEFAULT SYSDATE	NOT NULL
, POINT            NUMBER		    NULL
, PG_CODE	       VARCHAR2(20)		NOT NULL
, PAR_READ_DATE	   DATE		        NULL
);
--==>> Table GEN_PAR_CONFIRMED_REFUNDED이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE GEN_PAR_CONFIRMED_REFUNDED
ADD ( CONSTRAINT GEN_PAR_CON_REFUNDED_ID_PK PRIMARY KEY(GEN_PAR_CONFIRMED_REFUNDED_ID) );
--==>> Table GEN_PAR_CONFIRMED_REFUNDED이(가) 변경되었습니다.

ALTER TABLE GEN_PAR_CONFIRMED_REFUNDED
ADD ( CONSTRAINT GEN_PAR_CON_CANCELED_ID_FK FOREIGN KEY(GEN_PAR_CONFIRMED_CANCELED_ID)      -- 테이블명 날림.
                 REFERENCES GEN_PAR_CONFIRMED_CANCELED(GEN_PAR_CONFIRMED_CANCELED_ID)
    , CONSTRAINT G_P_C_R_AMOUNT_CK CHECK(AMOUNT >= 0)
    , CONSTRAINT G_P_C_R_PAR_READ_DATE_CK CHECK(PAR_READ_DATE >= REFUNDED_DATE) );
--==>> Table GEN_PAR_CONFIRMED_REFUNDED이(가) 변경되었습니다.


--○ 일반 돌봄 예약 확정 후 취소(시터가 취소)
-- 테이블 생성
CREATE TABLE GEN_SIT_CONFIRMED_CANCELED
( GEN_SIT_CONFIRMED_CANCELED_ID	    VARCHAR2(20)
, REASON_CANCELED_ID	CHAR(3)		    NOT NULL
, GEN_CONFIRMED_ID      VARCHAR2(20)	NOT NULL
, CANCELED_DATE	        DATE	    DEFAULT SYSDATE	 NOT NULL
, PAR_READ_DATE         DATE		    NULL
, SIT_READ_DATE	        DATE		    NULL
);
--==>> Table GEN_SIT_CONFIRMED_CANCELED이(가) 생성되었습니다.

DESC GEN_SIT_CONFIRMED_CANCELED;

-- 제약 조건 부여
ALTER TABLE GEN_SIT_CONFIRMED_CANCELED
ADD ( CONSTRAINT GEN_SIT_CON_CANCELED_ID_PK PRIMARY KEY(GEN_SIT_CONFIRMED_CANCELED_ID) );
--==>> Table GEN_SIT_CONFIRMED_CANCELED이(가) 변경되었습니다.

ALTER TABLE GEN_SIT_CONFIRMED_CANCELED
ADD ( CONSTRAINT G_S_C_C_REASON_CANCELED_ID_FK FOREIGN KEY(REASON_CANCELED_ID)
                 REFERENCES REASON_CANCELED(REASON_CANCELED_ID)
    , CONSTRAINT G_S_C_C_GEN_CONFIRMED_ID_FK FOREIGN KEY(GEN_CONFIRMED_ID)
                 REFERENCES GEN_CONFIRMED(GEN_CONFIRMED_ID)
    , CONSTRAINT G_S_C_C_PAR_READ_DATE_CK CHECK(PAR_READ_DATE >= CANCELED_DATE)
    , CONSTRAINT G_S_C_C_SIT_READ_DATE_CK CHECK(SIT_READ_DATE >= CANCELED_DATE) );



--○ 일반 돌봄 예약 확정 후 취소 환불(시터)
-- 테이블 생성
CREATE TABLE GEN_SIT_CONFIRMED_REFUNDED
( GEN_SIT_CONFIRMED_REFUNDED_ID	VARCHAR2(20)
, GEN_SIT_CONFIRMED_CANCELEDED	VARCHAR2(20)	NOT NULL
, AMOUNT	           NUMBER		    NOT NULL
, REFUNDED_DATE        DATE	    DEFAULT SYSDATE	NOT NULL
, POINT                NUMBER		    NULL
, PG_CODE              VARCHAR2(20)		NOT NULL
, PAR_READ_DATE	       DATE		        NULL
);
--==>> Table GEN_SIT_CONFIRMED_REFUNDED이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE GEN_SIT_CONFIRMED_REFUNDED
ADD ( CONSTRAINT GEN_SIT_CON_REFUNDED_ID_PK PRIMARY KEY(GEN_SIT_CONFIRMED_REFUNDED_ID) );
--==>> Table GEN_SIT_CONFIRMED_REFUNDED이(가) 변경되었습니다.

ALTER TABLE GEN_SIT_CONFIRMED_REFUNDED
ADD ( CONSTRAINT GEN_SIT_CON_CANCELED_ID_FK FOREIGN KEY(GEN_SIT_CONFIRMED_CANCELEDED)      -- 테이블명 날림.
                 REFERENCES GEN_SIT_CONFIRMED_CANCELED(GEN_SIT_CONFIRMED_CANCELED_ID)
    , CONSTRAINT G_S_C_R_AMOUNT_CK CHECK(AMOUNT >= 0)
    , CONSTRAINT G_S_C_R_PAR_READ_DATE_CK CHECK(PAR_READ_DATE >= REFUNDED_DATE) );



--○ 일반 돌봄 리뷰
-- 테이블 생성
CREATE TABLE GEN_REVIEWS
( GEN_REVIEW_ID	    VARCHAR2(20)
, GEN_CONFIRMED_ID	VARCHAR2(20)	NOT NULL
, RATING        	NUMBER		    NOT NULL
, REVIEWED_DATE    	DATE		    DEFAULT SYSDATE	NOT NULL
, POINT_AMOUNT  	NUMBER	    	NOT NULL
, POINT_SUBJECT 	VARCHAR2(10)	NOT NULL
, USED_TIME     	NUMBER		    NOT NULL
, PAR_READ_DATE 	DATE		    NULL
);
--==>> Table GEN_REVIEWS이(가) 생성되었습니다.

-- 제약조건 부여
ALTER TABLE GEN_REVIEWS
ADD ( CONSTRAINT GEN_REVIEW_ID_PK PRIMARY KEY(GEN_REVIEW_ID) );
--==>> Table GEN_REVIEWS이(가) 변경되었습니다.

ALTER TABLE GEN_REVIEWS
ADD ( CONSTRAINT GEN_REVIEWS_GEN_CON_ID_FK FOREIGN KEY(GEN_CONFIRMED_ID)
                 REFERENCES GEN_CONFIRMED(GEN_CONFIRMED_ID)
    , CONSTRAINT GEN_REVIEWS_RATING_CK CHECK(RATING BETWEEN 1 AND 5)
    , CONSTRAINT GEN_REVIEWS_POINT_AMOUNT_CK CHECK(POINT_AMOUNT >= 0)
    , CONSTRAINT GEN_REVIEWS_PAR_READ_DATE_CK CHECK(PAR_READ_DATE >= REVIEWED_DATE)
);
--==>> Table GEN_REVIEWS이(가) 변경되었습니다.



--○ 일반 돌봄 객관식 응답
-- 테이블 생성
CREATE TABLE GEN_MULTIPLE_REVIEWS
( GEN_MULTIPLE_REVIEW_ID	VARCHAR2(20)
, GEN_REVIEW_ID     	    VARCHAR2(20)		NOT NULL
, GEN_MULTIPLE_TYPE_ID	    CHAR(3)	        	NOT NULL
);
--==>> Table GEN_MULTIPLE_REVIEWS이(가) 생성되었습니다.

-- 제약조건 부여
ALTER TABLE GEN_MULTIPLE_REVIEWS
ADD (CONSTRAINT GEN_MULTIPLE_REVIEW_ID_PK PRIMARY KEY(GEN_MULTIPLE_REVIEW_ID));
--==>> Table GEN_MULTIPLE_REVIEWS이(가) 변경되었습니다.

ALTER TABLE GEN_MULTIPLE_REVIEWS
ADD ( CONSTRAINT G_M_R_GEN_REVIEW_ID_FK FOREIGN KEY(GEN_REVIEW_ID)
                 REFERENCES GEN_REVIEWS(GEN_REVIEW_ID)
    , CONSTRAINT G_M_R_GEN_MULTIPLE_TYPE_ID_FK FOREIGN KEY(GEN_MULTIPLE_TYPE_ID)
                 REFERENCES GEN_MULTIPLE_TYPES(GEN_MULTIPLE_TYPE_ID) );
--==>> Table GEN_MULTIPLE_REVIEWS이(가) 변경되었습니다.



--○ 돌봄 객관식 응답 종류
-- 테이블 생성
CREATE TABLE GEN_MULTIPLE_TYPES
( GEN_MULTIPLE_TYPE_ID	CHAR(3)
, TYPE              	VARCHAR2(20)	NOT NULL
);
--==>> Table GEN_MULTIPLE_TYPES이(가) 생성되었습니다.

-- 제약 조건 부여
ALTER TABLE GEN_MULTIPLE_TYPES
ADD ( CONSTRAINT GEN_MULTIPLE_TYPE_ID_PK PRIMARY KEY(GEN_MULTIPLE_TYPE_ID));
--==>> Table GEN_MULTIPLE_TYPES이(가) 변경되었습니다.
