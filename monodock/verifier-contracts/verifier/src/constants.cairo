use bn::g::{AffineG1, AffineG2, g1, g2};
use bn::fields::{fq, fq2, fq12, Fq12};

fn vk() -> (
    AffineG1, AffineG2, AffineG2, AffineG2, Fq12, AffineG1, AffineG1, AffineG1, AffineG1, AffineG1
) {
    let mut alpha = g1(
        20491192805390485299153009773594534940189261866228447918068658471970481763042,
        9383485363053290200918347156157836566562967994039712273449902621266178545958
    );
    let beta_neg = g2(
        6375614351688725206403948262868962793625744043794305715222011528459656738731,
        4252822878758300859123897981450591353533073413197771768651442665752259397132,
        11383000245469012944693504663162918391286475477077232690815866754273895001727,
        41207766310529818958173054109690360505148424997958324311878202295167071904
    );
    let gamma_neg = g2(
        10857046999023057135944570762232829481370756359578518086990519993285655852781,
        11559732032986387107991004021392285783925812861821192530917403151452391805634,
        13392588948715843804641432497768002650278120570034223513918757245338268106653,
        17805874995975841540914202342111839520379459829704422454583296818431106115052
    );
    let delta_neg = g2(
        16243966861079634958125511652590761846958471358623040426599000904006426210032,
        13406811599156507528361773763681356312643537981039994686313383243831956396116,
        6200159192601353057572886987075813506094457284081503951532640457043392212361,
        10106646337257131644126001022517996571132285659724751907435065628753338091209
    );
    let ic_0 = g1(
        1964404930528116823793003656764176108669615750422202377358993070935069307720,
        2137714996673694828207437580381836490878070731768805974506391024595988817424
    );
    let ic_1 = g1(
        19568893707760843340848992184233194433177372925415116053368211122719346671126,
        11639469568629189918046964192305250472192697612201524135560178632824282818614
    );
    let ic_2 = g1(
        5317268879687484957437879782519918549127939892210247573193613900261494313825,
        528174394975085006443543773707702838726735933116136102590448357278717993744
    );
    let ic_3 = g1(
        14865918005176722116473730206622066845866539143554731094374354951675249722731,
        3197770568483953664363740385883457803041685902965668289308665954510373380344
    );
    let ic_4 = g1(
        6863358721495494421022713667808247652425178970453300712435830652679038918987,
        15025816433373311798308762709072064417001390853103872064614174594927359131281
    );

    let alphabeta_miller = fq12(
        17982990786055814898410670235621097176189607889436511936924954704631385294096,
        7370745665084505699383913205262777730385018642009986756866442182895636977140,
        20960052067223350509842507333760491808556439603157190996607963775825031694617,
        749286674754197593968889534550537728292984388023756273683853714989796388974,
        11643099789052251278410564227742280020486403735960111135209354264647385961722,
        401355266811213693999266106175416163444785447194710626978781614043084839590,
        9772164900355381119129445587723413557807803632571122940552376038381857383010,
        6961005744266956155677653216335397502509734685207818467245795912854674192678,
        15878894104505557618127248173376411673509961998343530071394540276500262389546,
        20247668928143051489451915669215255373960358330209295928945817639395738284987,
        5354320045056882417432930548320659521750575279725870865704183494487921663126,
        963403946964613772896867539128572598578821577616754289101475466468400638634
    );
    (alpha, beta_neg, gamma_neg, delta_neg, alphabeta_miller, ic_0, ic_1, ic_2, ic_3, ic_4)
}

