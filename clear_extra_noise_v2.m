function image = clear_extra_noise_v2(yourImage1,h)

        % clearning extra noise
        test_image1 = yourImage1;
        for im = 1:h
            nz(im) = nnz(yourImage1(:,:,im));
        end
        
        nz = nz./max(nz);

        [~, idx1] = find(nz == 1);

        nz0p5 = abs(nz - 0.5);
        nz0p5 = nz0p5(1:idx1);
        [~, idx2] = min(nz0p5);

        for im = 1:(idx2)
            yourImage1(:,:,im) = 0;
        end

        BW = imbinarize(yourImage1);

        for im = idx2 + 1:h
            image_plane = BW(:,:,im);
            [L,n] = bwlabel(image_plane,8);
            if n == 1
                [bincounts, binedges] = histcounts(L,n+ 1);
            else
               [bincounts, binedges] = histcounts(L,n);
            end
            bincounts = bincounts(2:end);
            binedges = binedges(2:end);
            
            [max_val,add_val] = max(bincounts);
            
            L(L == add_val) = n + 100;
            L(L < n+1) = 0;
     
            L1 = imbinarize(L);
            
            BW(:,:,im) = L1;
            clearvars image_plane L n bincounts binedges max_val add_val L1
        end

        [L,n] = bwlabeln(BW);
        if n == 1
                [bincounts, binedges] = histcounts(L,n+ 1);
            else
               [bincounts, binedges] = histcounts(L,n);
            end
        bincounts = bincounts(2:end);
        binedges = binedges(2:end);
        [~, add_val] = max(bincounts);
        L(L == add_val) = n + 100;
        L(L < n+1) = 0;
        
        L1 = imbinarize(L);



        image  = L1;



end
    