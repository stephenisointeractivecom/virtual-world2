﻿/* * SHA-512 for ActionScript * Ported by: AAA * Ported from: See below *//* * A JavaScript implementation of the Secure Hash Algorithm, SHA-512, as defined * in FIPS 180-2 * Version 2.2 Copyright Anonymous Contributor, Paul Johnston 2000 - 2009. * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet * Distributed under the BSD License * See http://pajhome.org.uk/crypt/md5 for details. */package scripts.encryption {        public class Sha512 {                public var hexcase = 0;                public var b64pad  = "";                public function Sha512() {                }                public function hex_sha512(s) { return rstr2hex(rstr_sha512(str2rstr_utf8(s))); }                public function b64_sha512(s) { return rstr2b64(rstr_sha512(str2rstr_utf8(s))); }                public function any_sha512(s, e) { return rstr2any(rstr_sha512(str2rstr_utf8(s)), e);}                public function hex_hmac_sha512(k, d) { return rstr2hex(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d))); }                public function b64_hmac_sha512(k, d) { return rstr2b64(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d))); }                public function any_hmac_sha512(k, d, e) { return rstr2any(rstr_hmac_sha512(str2rstr_utf8(k), str2rstr_utf8(d)), e);}                public function sha512_vm_test() {                        return hex_sha512("abc").toLowerCase() == "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a"                                                                                                        + "2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f";                }                private function rstr_sha512(s) {                        return binb2rstr(binb_sha512(rstr2binb(s), s.length * 8));                }                private function rstr_hmac_sha512(key, data) {                        var bkey = rstr2binb(key);                        if(bkey.length > 32) bkey = binb_sha512(bkey, key.length * 8);                        var ipad = new Array(32)                        var opad = new Array(32);                        for(var i = 0; i < 32; i++) {                                ipad[i] = bkey[i] ^ 0x36363636;                                opad[i] = bkey[i] ^ 0x5C5C5C5C;                        }                        var hash = binb_sha512(ipad.concat(rstr2binb(data)), 1024 + data.length * 8);                        return binb2rstr(binb_sha512(opad.concat(hash), 1024 + 512));                }                private function rstr2hex(input) {                        try { hexcase } catch(e) { hexcase=0; }                        var hex_tab = hexcase ? "0123456789ABCDEF" : "0123456789abcdef";                        var output = "";                        var x;                        for(var i = 0; i < input.length; i++) {                                x = input.charCodeAt(i);                                output += hex_tab.charAt((x >>> 4) & 0x0F) + hex_tab.charAt(x & 0x0F);                        }                        return output;                }                private function rstr2b64(input)                {                        try { b64pad } catch(e) { b64pad=''; }                        var tab = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";                        var output = "";                        var len = input.length;                        for(var i = 0; i < len; i += 3) {                                var triplet = (input.charCodeAt(i) << 16)                                | (i + 1 < len ? input.charCodeAt(i+1) << 8 : 0)                                | (i + 2 < len ? input.charCodeAt(i+2)      : 0);                                for(var j = 0; j < 4; j++) {                                        if(i * 8 + j * 6 > input.length * 8) output += b64pad;                                        else output += tab.charAt((triplet >>> 6*(3-j)) & 0x3F);                                }                        }                        return output;                }                private function rstr2any(input, encoding) {                        var divisor = encoding.length;                        var i, j, q, x, quotient;                        var dividend = new Array(Math.ceil(input.length / 2));                        for(i = 0; i < dividend.length; i++) {                                dividend[i] = (input.charCodeAt(i * 2) << 8) | input.charCodeAt(i * 2 + 1);                        }                        var full_length = Math.ceil(input.length * 8 / (Math.log(encoding.length) / Math.log(2)));                        var remainders = new Array(full_length);                        for(j = 0; j < full_length; j++) {                                quotient = new Array();                                x = 0;                                for(i = 0; i < dividend.length; i++) {                                        x = (x << 16) + dividend[i];                                        q = Math.floor(x / divisor);                                        x -= q * divisor;                                        if(quotient.length > 0 || q > 0)                                                quotient[quotient.length] = q;                                }                                remainders[j] = x;                                dividend = quotient;                        }                        var output = "";                        for(i = remainders.length - 1; i >= 0; i--)                                output += encoding.charAt(remainders[i]);                        return output;                }                private function str2rstr_utf8(input) {                        var output = "";                        var i = -1;                        var x, y;                        while(++i < input.length) {                                x = input.charCodeAt(i);                                y = i + 1 < input.length ? input.charCodeAt(i + 1) : 0;                                if(0xD800 <= x && x <= 0xDBFF && 0xDC00 <= y && y <= 0xDFFF) {                                        x = 0x10000 + ((x & 0x03FF) << 10) + (y & 0x03FF);                                        i++;                                }                                if(x <= 0x7F)                                        output += String.fromCharCode(x);                                else if(x <= 0x7FF)                                        output += String.fromCharCode(0xC0 | ((x >>> 6 ) & 0x1F), 0x80 | ( x         & 0x3F));                                else if(x <= 0xFFFF)                                        output += String.fromCharCode(0xE0 | ((x >>> 12) & 0x0F),                                    0x80 | ((x >>> 6 ) & 0x3F),                                    0x80 | ( x         & 0x3F));                                else if(x <= 0x1FFFFF)                                        output += String.fromCharCode(0xF0 | ((x >>> 18) & 0x07),                                    0x80 | ((x >>> 12) & 0x3F),                                    0x80 | ((x >>> 6 ) & 0x3F),                                    0x80 | ( x         & 0x3F));                        }                        return output;                }                private function str2rstr_utf16le(input) {                        var output = "";                        for(var i = 0; i < input.length; i++)                                output += String.fromCharCode( input.charCodeAt(i)        & 0xFF,                                  (input.charCodeAt(i) >>> 8) & 0xFF);                        return output;                }                private function str2rstr_utf16be(input) {                        var output = "";                        for(var i = 0; i < input.length; i++)                                output += String.fromCharCode((input.charCodeAt(i) >>> 8) & 0xFF,                                   input.charCodeAt(i)        & 0xFF);                        return output;                }                private function rstr2binb(input) {                        var output = new Array(input.length >> 2);                        for(var i = 0; i < output.length; i++)                                output[i] = 0;                        for(var a = 0; a < input.length * 8; a += 8)                                output[a>>5] |= (input.charCodeAt(a / 8) & 0xFF) << (24 - a % 32);                        return output;                }                private function binb2rstr(input) {                        var output = "";                        for(var i = 0; i < input.length * 32; i += 8)                                output += String.fromCharCode((input[i>>5] >>> (24 - i % 32)) & 0xFF);                        return output;                }                var sha512_k;                private function binb_sha512(x, len) {                        if(sha512_k == undefined) {                                sha512_k = new Array(                                        new Int64(0x428a2f98, -685199838), new Int64(0x71374491, 0x23ef65cd),                                        new Int64(-1245643825, -330482897), new Int64(-373957723, -2121671748),                                        new Int64(0x3956c25b, -213338824), new Int64(0x59f111f1, -1241133031),                                        new Int64(-1841331548, -1357295717), new Int64(-1424204075, -630357736),                                        new Int64(-670586216, -1560083902), new Int64(0x12835b01, 0x45706fbe),                                        new Int64(0x243185be, 0x4ee4b28c), new Int64(0x550c7dc3, -704662302),                                        new Int64(0x72be5d74, -226784913), new Int64(-2132889090, 0x3b1696b1),                                        new Int64(-1680079193, 0x25c71235), new Int64(-1046744716, -815192428),                                        new Int64(-459576895, -1628353838), new Int64(-272742522, 0x384f25e3),                                        new Int64(0xfc19dc6, -1953704523), new Int64(0x240ca1cc, 0x77ac9c65),                                        new Int64(0x2de92c6f, 0x592b0275), new Int64(0x4a7484aa, 0x6ea6e483),                                        new Int64(0x5cb0a9dc, -1119749164), new Int64(0x76f988da, -2096016459),                                        new Int64(-1740746414, -295247957), new Int64(-1473132947, 0x2db43210),                                        new Int64(-1341970488, -1728372417), new Int64(-1084653625, -1091629340),                                        new Int64(-958395405, 0x3da88fc2), new Int64(-710438585, -1828018395),                                        new Int64(0x6ca6351, -536640913), new Int64(0x14292967, 0xa0e6e70),                                        new Int64(0x27b70a85, 0x46d22ffc), new Int64(0x2e1b2138, 0x5c26c926),                                        new Int64(0x4d2c6dfc, 0x5ac42aed), new Int64(0x53380d13, -1651133473),                                        new Int64(0x650a7354, -1951439906), new Int64(0x766a0abb, 0x3c77b2a8),                                        new Int64(-2117940946, 0x47edaee6), new Int64(-1838011259, 0x1482353b),                                        new Int64(-1564481375, 0x4cf10364), new Int64(-1474664885, -1136513023),                                        new Int64(-1035236496, -789014639), new Int64(-949202525, 0x654be30),                                        new Int64(-778901479, -688958952), new Int64(-694614492, 0x5565a910),                                        new Int64(-200395387, 0x5771202a), new Int64(0x106aa070, 0x32bbd1b8),                                        new Int64(0x19a4c116, -1194143544), new Int64(0x1e376c08, 0x5141ab53),                                        new Int64(0x2748774c, -544281703), new Int64(0x34b0bcb5, -509917016),                                        new Int64(0x391c0cb3, -976659869), new Int64(0x4ed8aa4a, -482243893),                                        new Int64(0x5b9cca4f, 0x7763e373), new Int64(0x682e6ff3, -692930397),                                        new Int64(0x748f82ee, 0x5defb2fc), new Int64(0x78a5636f, 0x43172f60),                                        new Int64(-2067236844, -1578062990), new Int64(-1933114872, 0x1a6439ec),                                        new Int64(-1866530822, 0x23631e28), new Int64(-1538233109, -561857047),                                        new Int64(-1090935817, -1295615723), new Int64(-965641998, -479046869),                                        new Int64(-903397682, -366583396), new Int64(-779700025, 0x21c0c207),                                        new Int64(-354779690, -840897762), new Int64(-176337025, -294727304),                                        new Int64(0x6f067aa, 0x72176fba), new Int64(0xa637dc5, -1563912026),                                        new Int64(0x113f9804, -1090974290), new Int64(0x1b710b35, 0x131c471b),                                        new Int64(0x28db77f5, 0x23047d84), new Int64(0x32caab7b, 0x40c72493),                                        new Int64(0x3c9ebe0a, 0x15c9bebc), new Int64(0x431d67c4, -1676669620),                                        new Int64(0x4cc5d4be, -885112138), new Int64(0x597f299c, -60457430),                                        new Int64(0x5fcb6fab, 0x3ad6faec), new Int64(0x6c44198c, 0x4a475817));                        }                        var H = new Array(                                new Int64(0x6a09e667, -205731576),                                new Int64(-1150833019, -2067093701),                                new Int64(0x3c6ef372, -23791573),                                new Int64(-1521486534, 0x5f1d36f1),                                new Int64(0x510e527f, -1377402159),                                new Int64(-1694144372, 0x2b3e6c1f),                                new Int64(0x1f83d9ab, -79577749),                                new Int64(0x5be0cd19, 0x137e2179));                        var T1 = new Int64(0, 0),                        T2 = new Int64(0, 0),                        a = new Int64(0,0),                        b = new Int64(0,0),                        c = new Int64(0,0),                        d = new Int64(0,0),                        e = new Int64(0,0),                        f = new Int64(0,0),                        g = new Int64(0,0),                        h = new Int64(0,0),                        s0 = new Int64(0, 0),                        s1 = new Int64(0, 0),                        Ch = new Int64(0, 0),                        Maj = new Int64(0, 0),                        r1 = new Int64(0, 0),                        r2 = new Int64(0, 0),                        r3 = new Int64(0, 0);                        var j, i;                        var W = new Array(80);                        for(i=0; i<80; i++)                                W[i] = new Int64(0, 0);                        x[len >> 5] |= 0x80 << (24 - (len & 0x1f));                        x[((len + 128 >> 10)<< 5) + 31] = len;                        for(i = 0; i<x.length; i+=32) {                                a.copy(H[0]);                                b.copy(H[1]);                                c.copy(H[2]);                                d.copy(H[3]);                                e.copy(H[4]);                                f.copy(H[5]);                                g.copy(H[6]);                                h.copy(H[7]);                                for(j=0; j<16; j++) {                                        W[j].h = x[i + 2*j];                                        W[j].l = x[i + 2*j + 1];                                }                                for(j=16; j<80; j++) {                                        r1.rrot(W[j-2], 19);                                        r2.revrrot(W[j-2], 29);                                        r3.shr(W[j-2], 6);                                        s1.l = r1.l ^ r2.l ^ r3.l;                                        s1.h = r1.h ^ r2.h ^ r3.h;                                        r1.rrot(W[j-15], 1);                                        r2.rrot(W[j-15], 8);                                        r3.shr(W[j-15], 7);                                        s0.l = r1.l ^ r2.l ^ r3.l;                                        s0.h = r1.h ^ r2.h ^ r3.h;                                        W[j].add4(s1, W[j-7], s0, W[j-16]);                                }                                for(j = 0; j < 80; j++) {                                        Ch.l = (e.l & f.l) ^ (~e.l & g.l);                                        Ch.h = (e.h & f.h) ^ (~e.h & g.h);                                        r1.rrot(e, 14);                                        r2.rrot(e, 18);                                        r3.revrrot(e, 9);                                        s1.l = r1.l ^ r2.l ^ r3.l;                                        s1.h = r1.h ^ r2.h ^ r3.h;                                        r1.rrot(a, 28);                                        r2.revrrot(a, 2);                                        r3.revrrot(a, 7);                                        s0.l = r1.l ^ r2.l ^ r3.l;                                        s0.h = r1.h ^ r2.h ^ r3.h;                                        Maj.l = (a.l & b.l) ^ (a.l & c.l) ^ (b.l & c.l);                                        Maj.h = (a.h & b.h) ^ (a.h & c.h) ^ (b.h & c.h);                                        T1.add5(h, s1, Ch, sha512_k[j], W[j]);                                        T2.add(s0, Maj);                                        h.copy(g);                                        g.copy(f);                                        f.copy(e);                                        e.add(d, T1);                                        d.copy(c);                                        c.copy(b);                                        b.copy(a);                                        a.add(T1, T2);                                }                                H[0].add(H[0], a);                                H[1].add(H[1], b);                                H[2].add(H[2], c);                                H[3].add(H[3], d);                                H[4].add(H[4], e);                                H[5].add(H[5], f);                                H[6].add(H[6], g);                                H[7].add(H[7], h);                        }                        var hash = new Array(16);                        for(i=0; i<8; i++) {                                hash[2*i] = H[i].h;                                hash[2*i + 1] = H[i].l;                        }                        return hash;                }        }}