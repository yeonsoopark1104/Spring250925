<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Document</title>
        <script src="https://code.jquery.com/jquery-3.7.1.js"
            integrity="sha256-eKhayi8LEQwp4NKxN+CfCh+3qOVUtJn3QNZ0TciWLP4=" crossorigin="anonymous"></script>
        <script src="https://unpkg.com/vue@3/dist/vue.global.js"></script>
        <script type="text/javascript"
            src="//dapi.kakao.com/v2/maps/sdk.js?appkey=5e03846a5bae385cef3b2da33124bd8d&libraries=services"></script>
        <style>
            .map_wrap,
            .map_wrap * {
                margin: 0;
                padding: 0;
                font-family: 'Malgun Gothic', dotum, '돋움', sans-serif;
                font-size: 12px;
            }

            .map_wrap {
                position: relative;
                width: 100%;
                height: 350px;
            }

            #category {
                position: absolute;
                top: 10px;
                left: 10px;
                border-radius: 5px;
                border: 1px solid #909090;
                box-shadow: 0 1px 1px rgba(0, 0, 0, 0.4);
                background: #fff;
                overflow: hidden;
                z-index: 2;
            }

            #category li {
                float: left;
                list-style: none;
                width: 50px;
                px;
                border-right: 1px solid #acacac;
                padding: 6px 0;
                text-align: center;
                cursor: pointer;
            }

            #category li.on {
                background: #eee;
            }

            #category li:hover {
                background: #ffe6e6;
                border-left: 1px solid #acacac;
                margin-left: -1px;
            }

            #category li:last-child {
                margin-right: 0;
                border-right: 0;
            }

            #category li span {
                display: block;
                margin: 0 auto 3px;
                width: 27px;
                height: 28px;
            }

            #category li .category_bg {
                background: url(https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/places_category.png) no-repeat;
            }

            #category li .bank {
                background-position: -10px 0;
            }

            #category li .mart {
                background-position: -10px -36px;
            }

            #category li .pharmacy {
                background-position: -10px -72px;
            }

            #category li .oil {
                background-position: -10px -108px;
            }

            #category li .cafe {
                background-position: -10px -144px;
            }

            #category li .store {
                background-position: -10px -180px;
            }

            #category li.on .category_bg {
                background-position-x: -46px;
            }

            .placeinfo_wrap {
                position: absolute;
                bottom: 28px;
                left: -150px;
                width: 300px;
            }

            .placeinfo {
                position: relative;
                width: 100%;
                border-radius: 6px;
                border: 1px solid #ccc;
                border-bottom: 2px solid #ddd;
                padding-bottom: 10px;
                background: #fff;
            }

            .placeinfo:nth-of-type(n) {
                border: 0;
                box-shadow: 0px 1px 2px #888;
            }

            .placeinfo_wrap .after {
                content: '';
                position: relative;
                margin-left: -12px;
                left: 50%;
                width: 22px;
                height: 12px;
                background: url('https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/vertex_white.png')
            }

            .placeinfo a,
            .placeinfo a:hover,
            .placeinfo a:active {
                color: #fff;
                text-decoration: none;
            }

            .placeinfo a,
            .placeinfo span {
                display: block;
                text-overflow: ellipsis;
                overflow: hidden;
                white-space: nowrap;
            }

            .placeinfo span {
                margin: 5px 5px 0 5px;
                cursor: default;
                font-size: 13px;
            }

            .placeinfo .title {
                font-weight: bold;
                font-size: 14px;
                border-radius: 6px 6px 0 0;
                margin: -1px -1px 0 -1px;
                padding: 10px;
                color: #fff;
                background: #d95050;
                background: #d95050 url(https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/arrow_white.png) no-repeat right 14px center;
            }

            .placeinfo .tel {
                color: #0f7833;
            }

            .placeinfo .jibun {
                color: #999;
                font-size: 11px;
                margin-top: 0;
            }
        </style>
    </head>

    <body>
        <div id="app">
            <div class="map_wrap">
                <div id="map" style="width:100%;height:100%;position:relative;overflow:hidden;"></div>
                <ul id="category">
                    <li id="BK9" data-order="0">
                        <span class="category_bg bank"></span>
                        은행
                    </li>
                    <li id="MT1" data-order="1">
                        <span class="category_bg mart"></span>
                        마트
                    </li>
                    <li id="PM9" data-order="2">
                        <span class="category_bg pharmacy"></span>
                        약국
                    </li>
                    <li id="OL7" data-order="3">
                        <span class="category_bg oil"></span>
                        주유소
                    </li>
                    <li id="CE7" data-order="4">
                        <span class="category_bg cafe"></span>
                        카페
                    </li>
                    <li id="CS2" data-order="5">
                        <span class="category_bg store"></span>
                        편의점
                    </li>
                </ul>
            </div>
        </div>
    </body>

    </html>

    <script>
        const app = Vue.createApp({
            data() {
                return {
                    placeOverlay: null,
                    contentNode: null,
                    markers: [],
                    currCategory: '',
                    map: null,
                    ps: null
                };
            },
            methods: {
                addEventHandle(target, type, callback) {
                    if (target.addEventListener) {
                        target.addEventListener(type, callback);
                    } else {
                        target.attachEvent('on' + type, callback);
                    }
                },

                searchPlaces() {
                    if (!this.currCategory) return;

                    this.placeOverlay.setMap(null);
                    this.removeMarker();

                    this.ps.categorySearch(this.currCategory, this.placesSearchCB, { useMapBounds: true });
                },

                placesSearchCB(data, status, pagination) {
                    if (status === kakao.maps.services.Status.OK) {
                        this.displayPlaces(data);
                    } else if (status === kakao.maps.services.Status.ZERO_RESULT) {
                        // 결과 없음 처리
                    } else if (status === kakao.maps.services.Status.ERROR) {
                        // 에러 처리
                    }
                },

                displayPlaces(places) {
                    const order = document.getElementById(this.currCategory).getAttribute('data-order');

                    for (let i = 0; i < places.length; i++) {
                        const marker = this.addMarker(
                            new kakao.maps.LatLng(places[i].y, places[i].x),
                            order
                        );

                        kakao.maps.event.addListener(marker, 'click', () => {
                            this.displayPlaceInfo(places[i]);
                        });
                    }
                },

                addMarker(position, order) {
                    const imageSrc = 'https://t1.daumcdn.net/localimg/localimages/07/mapapidoc/places_category.png';
                    const imageSize = new kakao.maps.Size(27, 28);
                    const imgOptions = {
                        spriteSize: new kakao.maps.Size(72, 208),
                        spriteOrigin: new kakao.maps.Point(46, (order * 36)),
                        offset: new kakao.maps.Point(11, 28)
                    };
                    const markerImage = new kakao.maps.MarkerImage(imageSrc, imageSize, imgOptions);
                    const marker = new kakao.maps.Marker({
                        position: position,
                        image: markerImage
                    });

                    marker.setMap(this.map);
                    this.markers.push(marker);
                    return marker;
                },

                removeMarker() {
                    for (let i = 0; i < this.markers.length; i++) {
                        this.markers[i].setMap(null);
                    }
                    this.markers = [];
                },

                displayPlaceInfo(place) {
                    let content = '<div class="placeinfo">' +
                        '<a class="title" href="' + place.place_url + '" target="_blank" title="' + place.place_name + '">' + place.place_name + '</a>';

                    if (place.road_address_name) {
                        content += '<span title="' + place.road_address_name + '">' + place.road_address_name + '</span>' +
                            '<span class="jibun" title="' + place.address_name + '">(지번 : ' + place.address_name + ')</span>';
                    } else {
                        content += '<span title="' + place.address_name + '">' + place.address_name + '</span>';
                    }

                    content += '<span class="tel">' + place.phone + '</span>' +
                        '</div><div class="after"></div>';

                    this.contentNode.innerHTML = content;
                    this.placeOverlay.setPosition(new kakao.maps.LatLng(place.y, place.x));
                    this.placeOverlay.setMap(this.map);
                },

                addCategoryClickEvent() {
                    const category = document.getElementById('category');
                    const children = category.children;

                    for (let i = 0; i < children.length; i++) {
                        children[i].onclick = this.onClickCategory;
                    }
                },

                onClickCategory(event) {
                    const target = event.currentTarget || event.target;
                    const id = target.id;
                    const className = target.className;

                    this.placeOverlay.setMap(null);

                    if (className === 'on') {
                        this.currCategory = '';
                        this.changeCategoryClass();
                        this.removeMarker();
                    } else {
                        this.currCategory = id;
                        this.changeCategoryClass(target);
                        this.searchPlaces();
                    }
                },

                changeCategoryClass(el) {
                    const category = document.getElementById('category');
                    const children = category.children;

                    for (let i = 0; i < children.length; i++) {
                        children[i].className = '';
                    }

                    if (el) {
                        el.className = 'on';
                    }
                }
            },
            mounted() {
                const self = this;

                // 커스텀 오버레이 객체
                self.placeOverlay = new kakao.maps.CustomOverlay({ zIndex: 1 });

                // 커스텀 오버레이 내용 노드
                self.contentNode = document.createElement('div');
                self.contentNode.className = 'placeinfo_wrap';

                // 지도 생성
                const mapContainer = document.getElementById('map');
                const mapOption = {
                    center: new kakao.maps.LatLng(37.566826, 126.9786567),
                    level: 5
                };
                self.map = new kakao.maps.Map(mapContainer, mapOption);

                // 장소 검색 객체
                self.ps = new kakao.maps.services.Places(self.map);

                // idle 이벤트 등록
                kakao.maps.event.addListener(self.map, 'idle', self.searchPlaces);

                // 지도 클릭 방지 이벤트
                self.addEventHandle(self.contentNode, 'mousedown', kakao.maps.event.preventMap);
                self.addEventHandle(self.contentNode, 'touchstart', kakao.maps.event.preventMap);

                // 커스텀 오버레이 내용 설정
                self.placeOverlay.setContent(self.contentNode);

                // 카테고리 클릭 이벤트
                self.addCategoryClickEvent();
            }
        });

        app.mount('#app');
    </script>